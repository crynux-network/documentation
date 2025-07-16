---
description: How to define a text-to-text task
---

# Text-to-Text Task

The GPT Task framework has two components:

1. A generalized schema to define a llm text generation task.
2. An execution engine that runs the task defined in the above schema.

The task definition is represented in the key-value pairs that can be transformed into, among many other formats, a JSON string, which can be validated using a JSON schema. And the validation tools exist for most of the popular programming languages.

The execution engine is integrated into the node of the Helium Network, and the JSON string format of the task definition is used to send tasks in the Helium Network.

## GPT Task definition

The following is an intuitive look at a task definition:

```json
{
    "model": "gpt2",
	"messages": [
		{
			"role": "user",
			"content": "I want to create a chat bot. Any suggestions?"
		}
	],
	"generation_config": {
		"max_new_tokens": 30,
		"do_sample": true,
		"num_beams": 1,
		"temperature": 1.0,
		"typical_p": 1.0,
		"top_k": 20,
		"top_p": 1.0,
		"repetition_penalty": 1.0,
		"num_return_sequences": 1
	},
	"seed": 42,
	"dtype": "auto",
	"quantize_bits": 4
}
```

More examples of the different GPT tasks can be found [in the GitHub repository](https://github.com/crynux-network/gpt-task/tree/main/examples).

### Model

The base model could be any large language model suitable for text generation task.

The model should be a Huggingface model ID.

All huggingface models list in the [huggingface models page](https://huggingface.co/models?pipeline\_tag=text-generation\&sort=trending) can be used for base model.

For example:

```json
{
    "model": "mistralai/Mistral-7B-v0.1"
}
```

### Messages

Messages is a list of message objects comprising the conversation so far.

For example:

```json
{
	"messages": [
		{
			"role": "user",
			"content": "I want to create a chat bot. Any suggestions?"
		}
	]
}
```

#### Message Object

Message object has two fields: `role` and `content`.

The field `role` represents the role of message author, can be `user`, `assistant` and `system`.

The field `content` is the message content.

During execution, the messages will be formatted to a plain string using the model's chat template, and then be send to the model as input prompt. Accroding to the different message role, different tags defined by the model will be added around each message. However, some models have no chat template, in this situation all the message contents will be simply joined to a single string.

### Generation Config

Generation config is a set of parameters to control the text generation behavior of the model.

For example:

```json
{
   "generation_config": {
		"max_new_tokens": 30,
		"do_sample": true,
		"num_beams": 1,
		"temperature": 1.0,
		"typical_p": 1.0,
		"top_k": 20,
		"top_p": 1.0,
		"repetition_penalty": 1.0,
		"num_return_sequences": 1
	},
}
```

The meaning of each parameters in generation config can be found in the [huggingface generation config](https://huggingface.co/docs/transformers/main\_classes/text\_generation#transformers.GenerationConfig).

#### max\_new\_tokens

The maximum numbers of tokens to generate, ignoring the number of tokens in the input prompt.

#### do\_sample

Whether or not to use sampling ; use greedy decoding otherwise.

#### num\_beams

Number of beams for beam search. 1 means no beam search.

#### temperature

The value used to modulate the next token probabilities. The higher the temperature, the flattering the next token probabilities. When the temperature equals 0, the sampling will be downgraded to greedy decoding.

#### typical\_p

Local typicality measures how similar the conditional probability of predicting a target token next is to the expected conditional probability of predicting a random token next, given the partial text already generated. If set to float < 1, the smallest set of the most locally typical tokens with probabilities that add up to typical\_p or higher are kept for generation. See [this paper](https://arxiv.org/pdf/2202.00666.pdf) for more details.

#### top\_k

The number of highest probability vocabulary tokens to keep for top-k-filtering.

#### top\_p

If set to float < 1, only the smallest set of most probable tokens with probabilities that add up to top\_p or higher are kept for generation.

#### repetition\_penalty

The parameter for repetition penalty. 1.0 means no penalty. See [this paper](https://arxiv.org/pdf/1909.05858.pdf) for more details.

#### num\_return\_sequences

The number of independently computed returned sequences for each element in the batch.

### Seed

The seed used to initialize the random processes.

{% hint style="info" %}
Helium Network requires a deterministic algorithm for text generation, which means the text generated on the different nodes of the same deivces, given the same task definition, should be the same. This is a requirement for the consensus protocol to work. The seed is left as a required argument in the task definition so that all the nodes could use the same seed to initialize their random number generators, which will hopefully produce the same random numbers across all the nodes.

Beside the seed, the GPT Task Framework has been implemented to maximize the reproducibility.
{% endhint %}

### Dtype

Optional. Control the data precision for the model. Can be `float16`, `bfloat16`, `float32` or `auto`. When `dtype=auto`, the parameter `dtype` will be determined by the model's config file.

### Quantize\_bits

Optional. Control the model quantization type. Can be `4` or `8`. `4` means the INT4 quantization, `8` means the INT8 quantization.

## GPT Task Response

The following is an intuitive look at a task response:

```json
{
    "model": "gpt2",
    "choices": [
        {
            "finish_reason": "length",
            "message": {
                "role": "assistant",
                "content": "\n\nI have a chat bot, called \"Eleanor\" which was developed by my team on Skype. "
                "The only thing I will say is this",
            },
            "index": 0,
        }
    ],
    "usage": {"prompt_tokens": 11, "completion_tokens": 30, "total_tokens": 41},
}
```

## Model

The model used for text generation.

## Choices

A list of choice object. The count of choices equals the the parameter `num_return_sequences` in `generation_config` of task definition.

### Choice Object

A choice object has three fields, `finish_reason`, `message` and `index`.

`finish_reason` represents the finish reason of the generated message, can be `stop` or `length`. When finish reason is `stop`, means the generated text ends with an eos token and stops naturally. When finish reason is `length`, means the generated text is truncated by the output token length limit, which defines by the `max_new_tokens` parameter in `generation_config` of task definition.

`message` is a message object which is the same with message object used in task definition. The `role` of response message will always be `assistant`.

`index` is the index of the choice object in all choices, begins from 0.

## Usage

Usage represents the token used of this text generation task. It has three fields, `prompt_tokens`, `completion_tokens` and `total_tokens`.

`prompt_tokens` means the input prompt tokens count. `completion_tokens` means the sum of all choices content tokens count. `total_tokens` is the sum of `prompt_tokens` and `completion_tokens`.
