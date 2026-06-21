[⬅️](Claude_API.md)

## 📝 TL;DR

Офіційний Java SDK для Claude API (`com.anthropic:anthropic-java`). Використовує immutable builder pattern, підтримує sync і async виконання, streaming, tool use через анотації і pagination через `autoPager()`. Вимагає Java 8+.

## Встановлення

```kotlin
// Gradle
implementation("com.anthropic:anthropic-java:2.40.0")
```

```xml
<!-- Maven -->
<dependency>
    <groupId>com.anthropic</groupId>
    <artifactId>anthropic-java</artifactId>
    <version>2.40.0</version>
</dependency>
```

Залежності: Jackson 2.13.4+, OkHttp (в `anthropic-java-client-okhttp`).

## Клієнт

```java
// Читає ANTHROPIC_API_KEY з env або system property anthropic.apiKey
AnthropicClient client = AnthropicOkHttpClient.fromEnv();

// Явно
AnthropicClient client = AnthropicOkHttpClient.builder()
    .apiKey("my-key")
    .build();
```

**Один клієнт на застосунок** — кожен клієнт має власний connection pool і thread pools.

## Базовий запит

```java
MessageCreateParams params = MessageCreateParams.builder()
    .model(Model.CLAUDE_OPUS_4_8)
    .maxTokens(1024L)
    .addUserMessage("Hello, Claude")
    .build();

Message message = client.messages().create(params);
System.out.println(message.content().get(0).text());
```

## Async

```java
// Перемикання до async на льоту
CompletableFuture<Message> future = client.async().messages().create(params);

// Або async клієнт одразу
AnthropicClientAsync asyncClient = AnthropicOkHttpClientAsync.fromEnv();
```

## Streaming

```java
// Sync streaming
try (StreamResponse<RawMessageStreamEvent> stream =
        client.messages().createStreaming(params)) {
    stream.stream().forEach(chunk -> System.out.println(chunk));
}

// Async streaming
client.async().messages().createStreaming(params)
    .subscribe(chunk -> System.out.println(chunk));
```

### MessageAccumulator

Вирішує одну проблему: при стримінгу є чанки, але немає структурованого `Message` після завершення. `MessageAccumulator` дозволяє мати streaming UX і structured result одночасно.

**Без accumulator** — текст у реальному часі, але після закриття стріму немає `stop_reason`, `usage`, `content` blocks.

**З accumulator** — `peek(acc::accumulate)` записує кожен event side-effectно, потім `acc.message()` повертає повний об'єкт:

```java
MessageAccumulator acc = MessageAccumulator.create();

try (StreamResponse<RawMessageStreamEvent> stream =
        client.messages().createStreaming(params)) {
    stream.stream()
        .peek(acc::accumulate)               // записує кожен event
        .flatMap(e -> e.contentBlockDelta().stream())
        .flatMap(e -> e.delta().text().stream())
        .forEach(delta -> System.out.print(delta.text())); // streaming UX
}

Message message = acc.message();
message.stopReason();  // "end_turn", "tool_use" тощо
message.usage();       // inputTokens, outputTokens
message.content();     // повні ContentBlock-и
```

Всередині accumulator отримує події `message_start`, `content_block_start`, `content_block_delta`, `content_block_stop`, `message_delta`, `message_stop` — склеює дельти в цілі блоки і збирає метадані.

| Сценарій | Потрібен accumulator? |
| --- | --- |
| Показати текст користувачу, без подальшої обробки | Ні |
| Показати текст + перевірити `stop_reason == "tool_use"` | Так |
| Agentic loop — стримінг + перевірка tool_use block | Так |
| Логування `usage` разом зі стримінгом | Так |

## Tool use через анотації

SDK автоматично генерує JSON schema з Java класу — назви полів стають параметрами інструменту.

```java
@JsonClassDescription("Get the weather in a given location")
static class GetWeather {

    @JsonPropertyDescription("The city and state, e.g. San Francisco, CA")
    public String location;

    @JsonPropertyDescription("The unit of temperature")
    public Unit unit;

    public Weather execute() { /* ... */ }
}
```

```java
// Реєстрація інструменту
params.addTool(GetWeather.class)

// Парсинг відповіді
GetWeather tool = toolUseBlock.input(GetWeather.class);
```

**Конвенція назв:** `GetWeather` → `get_weather`, `MyJSONParser` → `my_json_parser`. Override через `@JsonTypeName`.

**Вимога:** клас має бути top-level або `static` nested (Jackson не може інстанціювати non-static inner class).

### Корисні анотації

| Анотація | Призначення |
| --- | --- |
| `@JsonClassDescription` | Опис інструменту (коли і як використовувати) |
| `@JsonTypeName` | Override назви інструменту |
| `@JsonPropertyDescription` | Опис параметру |
| `@JsonIgnore` | Виключити public поле зі schema |
| `@JsonProperty` | Включити non-public поле у schema |

## Immutable builders

Всі об'єкти immutable після `build()`. `toBuilder()` для модифікованих копій без side effects:

```java
MessageCreateParams modified = params.toBuilder()
    .maxTokens(2048L)
    .build();
```

## Обробка помилок

```java
try {
    Message msg = client.messages().create(params);
} catch (RateLimitException e) {
    // 429 — можна retry після e.headers()
} catch (UnauthorizedException e) {
    // 401 — невірний API key
} catch (AnthropicServiceException e) {
    // будь-яка HTTP помилка: e.statusCode()
} catch (AnthropicIoException e) {
    // мережеві помилки
}
```

Auto-retry: 2 спроби за замовчуванням (408, 409, 429, 5xx). Налаштування: `.maxRetries(4)`.

## Pagination

```java
// Автоматична pagination
BatchListPage page = client.messages().batches().list();

for (MessageBatch batch : page.autoPager()) {
    System.out.println(batch);
}

// Stream з лімітом
page.autoPager().stream().limit(50).forEach(System.out::println);
```

## Timeout

За замовчуванням 10 хвилин. Для streaming з великим `maxTokens` — динамічний (до 60 хвилин).

```java
Message msg = client.messages().create(
    params,
    RequestOptions.builder().timeout(Duration.ofSeconds(30)).build()
);
```

## Логування

```bash
export ANTHROPIC_LOG=info   # базове логування
export ANTHROPIC_LOG=debug  # verbose (OkHttp interceptor)
```

## Platform integrations

| Платформа | Dependency | Backend |
| --- | --- | --- |
| Amazon Bedrock | `anthropic-java-bedrock` | `BedrockMantleBackend.fromEnv()` |
| Vertex AI | `anthropic-java-vertex` | `VertexBackend.fromEnv()` |
| Microsoft Foundry | `anthropic-java-foundry` | `FoundryBackend.fromEnv()` |

```java
AnthropicClient client = AnthropicOkHttpClient.builder()
    .fromEnv()
    .backend(BedrockMantleBackend.fromEnv())
    .build();
```

## Пов'язані нотатки

- [Огляд Claude API](claude_api_overview.md) — що таке Claude API, auth, SDK загалом
- [Tool Use API](tool_use_api.md) — теорія tool use (tools[], tool_choice, agentic loop)
- [Batch Messages API](batch_api.md) — batch під `client.messages().batches()`
