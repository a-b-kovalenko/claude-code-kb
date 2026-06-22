[⬅️](Claude_API.md)

## 📝 TL;DR

Claude API (колишній Anthropic API) — REST інтерфейс для прямого доступу до Claude моделей з коду. На відміну від Claude Code CLI, тут немає готового агентського режиму: ти сам будуєш логіку навколо `POST /v1/messages`.

## Що це

Anthropic надає HTTP API для виклику Claude моделей з будь-якої мови програмування. Центральний ендпоінт — `/v1/messages`. Офіційні SDK: Python, TypeScript/JavaScript, Java.

```python
import anthropic

client = anthropic.Anthropic()  # читає ANTHROPIC_API_KEY з env
response = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello"}]
)
print(response.content[0].text)
```

```java
import com.anthropic.client.okhttp.AnthropicOkHttpClient;

var client = AnthropicOkHttpClient.fromEnv(); // читає ANTHROPIC_API_KEY з env

var msg = client.messages().create(
    MessageCreateParams.builder()
        .model("claude-opus-4-8")
        .maxTokens(1024)
        .addUserMessage("Hello, Claude")
        .build()
);
System.out.println(msg.content().get(0).text());
```

Java SDK використовує builder pattern (`MessageCreateParams.builder()`) і OkHttp як HTTP клієнт. `fromEnv()` читає `ANTHROPIC_API_KEY` з оточення.

## Для чого

| Use case | Чому API, а не Claude Code |
| --- | --- |
| Власний продукт / web app | Потрібна інтеграція в бекенд, Claude Code — це CLI для розробника |
| Batch обробка 10k+ документів | Batch API зі знижкою 50% — не доступно через Claude Code |
| Складний agentic loop з кастомною логікою | Повний контроль над tool results, routing, retry |
| CI/CD pipeline без інтерактивності | Headless виклик, JSON stdout |
| Мобільний/десктоп додаток | REST API інтегрується де завгодно |

## API vs Claude Code CLI

| | Claude API | Claude Code CLI |
| --- | --- | --- |
| Що це | HTTP REST API | AI-агент поверх API |
| Контекст | Ти керуєш messages[] | Агент керує сам |
| Tools | Ти визначаєш і викликаєш | Вбудовані (Read, Edit, Bash, ...) |
| Agentic loop | Ти будуєш | Вбудований |
| Для кого | Розробники що будують продукти | Розробники що пишуть код |

Claude Code — це продукт побудований на Claude API. Знання API допомагає розуміти що відбувається "під капотом" Claude Code.

## Базова структура запиту

```json
{
  "model": "claude-sonnet-4-6",
  "max_tokens": 1024,
  "system": "You are a helpful assistant.",
  "messages": [
    {"role": "user", "content": "What is 2+2?"},
    {"role": "assistant", "content": "4."},
    {"role": "user", "content": "Why?"}
  ]
}
```

Поле `messages` — масив turns. `system` — системний промпт (окреме поле, не в messages).

## Аутентифікація

```bash
export ANTHROPIC_API_KEY="sk-ant-..."
```

SDK автоматично читає `ANTHROPIC_API_KEY` з оточення. Для прямих HTTP запитів:

```http
x-api-key: sk-ant-...
anthropic-version: 2023-06-01
```

## Пов'язані нотатки

- [🔢 Токени та токенізація](../Tokens_and_Tokenization.md) — базова одиниця API: що таке токен, BPE, англійська vs українська
- [Основи агентської розробки](../Agentry_Basics.md) — концептуальне порівняння API vs Claude Code CLI з точки зору вибору інструменту
- [Tool Use API](tool_use_api.md) — як додати інструменти до запиту
- [Prompt Caching API](prompt_caching_api.md) — зниження вартості повторних запитів
- [Batch Messages API](batch_api.md) — асинхронна обробка великих обсягів
- [Claude API — Огляд](Claude_API.md)
