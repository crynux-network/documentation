---
description: How to define a text-to-music task
---

# Text-to-Music Task

The Audio Task framework has two components:

1. A generalized schema to define a text-to-audio generation task.
2. An execution engine that runs the task defined in the above schema.

The task definition is represented in the key-value pairs that can be transformed into, among many other formats, a JSON string, which can be validated using a JSON schema. And the validation tools exist for most of the popular programming languages.

The execution engine is integrated into the node of the Helium Network, and the JSON string format of the task definition is used to send tasks in the Helium Network.

## Audio Task definition

The following is an intuitive look at a task definition:

```json
{
    "model": "facebook/musicgen-small",
    "prompt": "80s pop track with bassy drums and synth",
    "generation_config": {
        "max_new_tokens": 1500,
        "do_sample": true,
        "top_k": 250,
        "top_p": 0.0,
        "temperature": 1.0,
        "guidance_scale": 3.0
    },
    "seed": 42,
    "dtype": "auto",
    "quantize_bits": 8
}
```

More examples of the different audio tasks can be found [in the GitHub repository](https://github.com/crynux-network/audio-task/tree/main/examples).

### Model

The base model could be any model suitable for the [transformers.TextToAudioPipeline](https://huggingface.co/docs/transformers/main_classes/pipelines#transformers.TextToAudioPipeline).

The model should be a Huggingface model ID.

You can find the available huggingface models list in the [huggingface models page](https://huggingface.co/models?pipeline_tag=text-to-audio&sort=trending).

For example:

```json
{
    "model": "facebook/musicgen-small"
}
```

### Prompt

Prompt is a string used to control the audio generation.

For example:

```json
{
	"prompt": "80s pop track with bassy drums and synth"
}
```

### Generation Config

Generation config is a set of parameters to control the text generation behavior of the model.

For example:

```json
{
    "generation_config": {
        "max_new_tokens": 1500,
        "do_sample": true,
        "top_k": 250,
        "top_p": 0.0,
        "temperature": 1.0,
        "guidance_scale": 3.0
    }
}
```

The meaning of each parameters in generation config can be found in the [huggingface generation config](https://huggingface.co/docs/transformers/main\_classes/text\_generation#transformers.GenerationConfig).

#### max\_new\_tokens

The maximum numbers of tokens to generate. This parameter controls the max time of generated audio. The parameter `max_new_tokens` has a corresponding relationship with the max time, and this relationship is determined by the architechture of model's audio decoder.

#### do\_sample

Whether or not to use sampling ; use greedy decoding otherwise.

#### temperature

The value used to modulate the next token probabilities. The higher the temperature, the flattering the next token probabilities. When the temperature equals 0, the sampling will be downgraded to greedy decoding.


#### top\_k

The number of highest probability vocabulary tokens to keep for top-k-filtering.

#### top\_p

If set to float < 1, only the smallest set of most probable tokens with probabilities that add up to top\_p or higher are kept for generation.

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

## Audio Task Response

The response of audio task is a tuple of generated audio waveform and its sampling rate.

The audio waveform is a `np.ndarray` of shape `(audio_length, channels)`. The sampling rate is an integer.

You can use the following code to write the generated audio waveform to file.

```python
import scipy
from audio_task.inference import run_task

# audio is the generated audio waveform, sr is the sampling rate
audio, sr = run_task(
    model="facebook/musicgen-small",
    prompt="80s pop track with bassy drums and synth",
)
scipy.io.wavfile.write("example.wav", rate=sr, data=audio)
```
