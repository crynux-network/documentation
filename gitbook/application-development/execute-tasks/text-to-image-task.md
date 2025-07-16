---
description: How to define a text-to-image task
---

# Text-to-Image Task

The Stable Diffusion Task Framework has two components:

1. A generalized schema to define a Stable Diffusion task.
2. An execution engine that runs the task defined in the above schema.

The task definition is represented in the key-value pairs that can be transformed into, among many other formats, a JSON string, which can be validated using a JSON schema. And the validation tools exist for most of the popular programming languages.

The execution engine is integrated into the node of the Hydrogen Network, and the JSON string format of the task definition is used to send tasks in the Hydrogen Network.

The following is an intuitive look at a task definition:

```json
{
    "version": "2.0.0",
    "base_model": {
        "name": "stabilityai/sdxl-turbo"
    },
    "prompt": "best quality, ultra high res, photorealistic++++, 1girl, desert, full shot, dark stillsuit, "
              "stillsuit mask up, gloves, solo, highly detailed eyes,"
              "hyper-detailed, high quality visuals, dim Lighting, ultra-realistic, sharply focused, octane render,"
              "8k UHD",
    "negative_prompt": "no moon++, buried in sand, bare hands, figerless gloves, "
                       "blue stillsuit, barefoot, weapon, vegetation, clouds, glowing eyes++, helmet, "
                       "bare handed, no gloves, double mask, simplified, abstract, unrealistic, impressionistic, "
                       "low resolution,",
    "task_config": {
        "num_images": 9,
        "steps": 1,
        "cfg": 0
    },
    "lora": {
        "model": "https://civitai.com/api/download/models/178048"
    },
    "controlnet": {
        "model": "diffusers/controlnet-canny-sdxl-1.0",
        "image_dataurl": "data:image/png;base64,12FE1373...",
        "preprocess": {
            "method": "canny"
        },
        "weight": 70
    },
    "scheduler": {
        "method": "EulerAncestralDiscreteScheduler",
        "args": {
            "timestep_spacing": "trailing"
        }
    }
}
```

More examples of the different Stable Diffusion tasks can be found [in the GitHub repository](https://github.com/crynux-network/stable-diffusion-task/tree/main/examples).

## Acceleration of the Image Generation

### SDXL Turbo

SDXL Turbo is an adversarial time-distilled [Stable Diffusion XL](https://huggingface.co/papers/2307.01952) (SDXL) model capable of running inference in as little as 1 step. To use SDXL Turbo in your task:

#### 1. Use the SDXL Turbo model as the base model:

```
"base_model": {
    "name": "crynux-network/sdxl-turbo"
},
```

#### 2. Set the `timestep_spacing` scheduler argument:

```
"scheduler": {
    "method": "EulerAncestralDiscreteScheduler",
    "args": {
        "timestep_spacing": "trailing"
    }
}
```

#### 3. Set `cfg` to zero, and set steps to 1-4:

```
"task_config": {
    "steps": 1,
    "cfg": 0
}
```

### Latent Consistency Models (LCM)

{% hint style="danger" %}
Negative prompts won't work with LCM methods.
{% endhint %}

[Latent Consistency Models (LCMs)](https://hf.co/papers/2310.04378) enable fast high-quality image generation by directly predicting the reverse diffusion process in the latent rather than pixel space. In other words, LCMs try to predict the noiseless image from the noisy image in contrast to typical diffusion models that iteratively remove noise from the noisy image. By avoiding the iterative sampling process, LCMs are able to generate high-quality images in 2-4 steps instead of 20-30 steps.

There are two ways LCM could be used in a Stable Diffusion task: LCM and LCM-LoRA:

{% tabs %}
{% tab title="LCM" %}
#### 1.Load the LCM model corresponding to your base model using the `unet` argument:

```
"base_model": {
    "name": "stabilityai/stable-diffusion-xl-base-1.0"
},
"unet": "latent-consistency/lcm-sdxl",
```

#### 2.Use the `LCMScheduler`:

```
"scheduler": {
    "method": "LCMScheduler"
}
```

#### 3.Set `cfg` to 3-13, and set `steps` to 4:

```
"task_config": {
    "steps": 4,
    "cfg": 5
},
```
{% endtab %}

{% tab title="LCM-LoRA" %}
#### 1. Load the LCM-LoRA model corresponding to your base model using `lora` argument:

```
"base_model": {
    "name": "runwayml/stable-diffusion-v1-5"
},
"lora": {
    "model": "latent-consistency/lcm-lora-sdv1-5"
},
```

#### 2. Use the `LCMScheduler`:

```
"scheduler": {
    "method": "LCMScheduler"
}
```

#### 2. Set the cfg to 1-2, and steps to 4:

```
"task_config": {
    "steps": 4,
    "cfg": 1
},
```
{% endtab %}
{% endtabs %}



## Base Model

The base model could be the original Stable Diffusion models, such as the Stable Diffusion 1.5 and the Stable Diffusion XL, or a checkpoint that is fine-tuned based on the original Stable Diffusion models.

The model can be specified in two ways: a Huggingface model ID, or a file download URL.

#### Huggingface Model ID

The Huggingface model ID for the original Stable Diffusion models are listed below:

* **Stable Diffusion 1.5**

```json
{
  "base_model": "runwayml/stable-diffusion-v1-5"
}
```

* **Stable Diffusion 2.1**

```json
{
  "base_model": "stabilityai/stable-diffusion-2-1"
}
```

* **Stable Diffusion XL**

```json
{
  "base_model": "stabilityai/stable-diffusion-xl-base-1.0"
}
```

* **Custom Fine-tuned Checkpoints**

Other custom fine-tuned checkpoints based on the original SD models can also be used, for example, the [ChilloutMix](https://huggingface.co/emilianJR/chilloutmix\_NiPrunedFp32Fix) model on the Huggingface:

```json
{
  "base_model": "emilianJR/chilloutmix_NiPrunedFp32Fix"
}
```

#### File Download URL

A URL can also be used as the base model. The execution engine will download the file before executing the task.

For example, if we want to use an SDXL fined-tuned checkpoint on Civitai. The webpage of the model is [https://civitai.com/models/169868/thinkdiffusionxl](https://civitai.com/models/169868/thinkdiffusionxl) and the download link of the model file can be copied from the download button on the webpage:&#x20;

[https://civitai.com/api/download/models/190908](https://civitai.com/api/download/models/190908)

We could use the model in the task as following:

```json
{
  "base_model": "https://civitai.com/api/download/models/190908"
}
```

{% hint style="info" %}
Only `safetensors` format is supported in the download URL.

The execution engine assumes the download URL to be a binary stream of a model file in the `safetensors` format. If other formats are used, or the content of the link is not a model file at all, the execution engine will throw an exception during the execution.
{% endhint %}

## LoRA Model

LoRA models can be specified using the same format as the base model: the Huggingface model ID or the file download URL. The weight of the LoRA model can also be set in the arguments:

```json
{
   "lora": {
     "model": "https://civitai.com/api/download/models/31284",
     "weight": 80
   }
}
```

The weight should be an integer between 1 and 100.

If the LoRA model given is not compatible with the base model, for example, a LoRA model fine-tuned on the Stable Diffusion 1.5 is used, but the base model is set to be Stable Diffusion XL, the execution engine will also throw an exception.

## Controlnet

The Controlnet section has two parts: the Controlnet model, and the preprocess method.&#x20;

The Controlnet model also supports the Huggingface ID and the download URL, which is exactly the same as the LoRA model.

The control image should be a PNG image encoded in the DataURL format. The DataURL string should be filled in the `image_dataurl` field.

```json
{
   "controlnet": {
      "model": "lllyasviel/control_v11p_sd15_openpose",
      "weight": 90,
      "image_dataurl": "base64,image/png:..."
   }
}
```

#### Image Preprocessing

The image preprocessing function is implemented using the [`controlnet_aux`](https://github.com/patrickvonplaten/controlnet\_aux) project. All the preprocessing methods and models in this project can be used:

```json
{
   "controlnet": {
      "model": "lllyasviel/sd-controlnet-canny",
      "weight": 90,
      "image_dataurl": "base64,image/png:...",
      "preprocess": {
         "method": "canny",
         "args": {
            "high_threshold": 200,
            "low_threshold": 100
         }
      }
   }
}
```

Here is a list of all the available preprocess methods and their arguments:

<table data-full-width="false"><thead><tr><th width="291">Method</th><th>Arguments</th></tr></thead><tbody><tr><td>canny</td><td>high_threshold, low_threshold</td></tr><tr><td>scribble_hed</td><td></td></tr><tr><td>scribble_hedsafe</td><td></td></tr><tr><td>softedge_hed</td><td></td></tr><tr><td>softedge_hedsafe</td><td></td></tr><tr><td>depth_midas</td><td></td></tr><tr><td>mlsd</td><td>thr_v, thr_d</td></tr><tr><td>openpose</td><td></td></tr><tr><td>openpose_face</td><td></td></tr><tr><td>openpose_faceonly</td><td></td></tr><tr><td>openpose_full</td><td></td></tr><tr><td>openpose_hand</td><td></td></tr><tr><td>dwpose</td><td></td></tr><tr><td>scribble_pidinet</td><td>apply_filter</td></tr><tr><td>softedge_pidinet</td><td>apply_filter</td></tr><tr><td>scribble_pidisafe</td><td>apply_filter</td></tr><tr><td>softedge_pidisafe</td><td>apply_filter</td></tr><tr><td>normal_bae</td><td></td></tr><tr><td>lineart_coarse</td><td></td></tr><tr><td>lineart_realistic</td><td></td></tr><tr><td>lineart_anime</td><td></td></tr><tr><td>depth_zoe</td><td>gamma_corrected</td></tr><tr><td>depth_leres</td><td>thr_a, thr_b</td></tr><tr><td>depth_leres++</td><td>thr_a, thr_b</td></tr><tr><td>shuffle</td><td>h, w, f</td></tr><tr><td>mediapipe_face</td><td>max_faces, min_confidence</td></tr></tbody></table>

If preprocessing is not needed, just set the value of the `controlnet` section to be null, or just delete the section from the JSON.

## Prompt

Unlike the basic SD models, the length of the prompt is not limited in this framework. The prompt and the negative prompt are specified separately:

```json
{
   "prompt": "a realistic portrait photo of a beautiful girl, blonde hair+++, smiling, facing the viewer",
   "negative_prompt": "low resolution++, bad hands"
}
```

#### Prompt Weighting

Prompt weighting is supported using the [Compel](https://github.com/damian0815/compel) library. The basic idea is to put more plus signs (`+`) to give the word more weights. More complex usages can be found in the documentation of the Compel library.

## Textual Inversion

Textual Inversion models are also supported:

```json
{
  "textual_inversion": "sd-concepts-library/cat-toy"
}
```

## VAE

The VAE model used in the Stable Diffusion pipeline can also be replaced with another one, either from the Huggingface ID, or a file download URL:

```json
{
  "vae": "stabilityai/sd-vae-ft-mse"
}
```

## SDXL Refiner

If the Stable Diffusion XL is selected as the base model in the task, the SDXL Refiner could also be used to further refine the image, which is by design of the SDXL:

```json
{
    "refiner": {
       "model": "stabilityai/stable-diffusion-xl-refiner-1.0",
       "denoising_cutoff": 80
    }
}
```

The `denoising_cutoff` is used to stop the denoising process earlier in the pipeline, when the noise level reaches the cutoff value, and leave the rest to the refiner model, which is called the [ensemble of expert denoisers](https://research.nvidia.com/labs/dir/eDiff-I/).

{% hint style="info" %}
If the Controlnet is used with the Stable Diffusion XL base model, the `denoising_cutoff` argument is not supported due to the current limitations in the [diffusers library](https://huggingface.co/docs/diffusers/index). If refiner is configured, it will be executed after the base model generation is completed, the cutoff value is ignored.
{% endhint %}

## Task Config

There are also some config options that can be tuned:

```json
{
   "task_config": {
     "image_width": 512,       // The width of the generated image
     "image_height": 512,      // The height of the generated image
     "steps": 30,              // Step to run
     "seed": 34736484,         // The seed used to initialize the random processes
     "num_images": 6,          // The number of images to generate in a single task
     "safety_checker": true,   // Filter the unsafe images
     "cfg": 5                  // Classifier-Free Guidance, how close the images should be to the prompt given
   }
}
```

{% hint style="info" %}
Hydrogen Network requires a deterministic image generation process, which means the images generated on the different nodes, given the same task definition, should be as close as possible. This is a requirement for the consensus protocol to work. The seed is left as a required argument in the task definition so that all the nodes could use the same seed to initialize their random number generators, which will hopefully produce the same random numbers across all the nodes.

Beside the seed, the Stable Diffusion Task Framework has been implemented to maximize the reproducibility, for all the components used, across the whole image generation process.&#x20;
{% endhint %}
