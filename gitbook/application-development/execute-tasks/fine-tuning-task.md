# Fine-Tuning Task

The fine tuning task aims to fine tune a lora model for a pretrained stable diffusion model. It has two components:

1. A generalized schema to define a Fine tuning task.
2. An execution engine that runs the task defined in the above schema.

The task definition is represented in the key-value pairs that can be transformed into, among many other formats, a JSON string, which can be validated using a JSON schema. And the validation tools exist for most of the popular programming languages.

The execution engine is integrated into the node of the Hydrogen Network, and the JSON string format of the task definition is used to send tasks in the Hydrogen Network.

## Fine tuning Task definition

The following is an intuitive look at a task definition:

```json
{
    "model": {
        "name": "runwayml/stable-diffusion-v1-5",
        "revision": "main",
    },
    "dataset": {
        "name": "lambdalabs/naruto-blip-captions",
        "image_column": "image",
        "caption_column": "text",
    },
    "validation": {
        "num_images": 4,
    },
    "train_args": {
        "learning_rate": 1e-4,
        "batch_size": 1,
        "gradient_accumulation_steps": 4,
        "num_train_steps": 100,
        "max_train_steps": 15000,
        "scale_lr": true,
        "resolution": 512,
        "noise_offset": 0,
        "lr_scheduler": {
            "lr_scheduler": "cosine",
            "lr_warmup_steps": 500,
        },
        "adam_args": {
            "beta1": 0.9,
            "beta2": 0.999,
            "weight_decay": 0.01,
            "epsilon": 1e-8
        }
    },
    "lora": {
        "rank": 4,
        "init_lora_weights": "gaussian",
        "target_modules": ["to_k", "to_q", "to_v", "to_out.0"]
    },
    "transforms": {
        "center_crop": true,
        "random_flip": true,
    },
    "dataloader_num_workers": 2,
    "mixed_precision": "fp16",
    "seed": 1337,
    "checkpoint": null,
    "version": "2.1.0"
}
```

Full example of the fine tuning task can be found [in the GitHub repository](https://github.com/crynux-network/stable-diffusion-task/tree/main/examples/finetune_lora.py).

### model

```json
{
    "model": {
        "name": "runwayml/stable-diffusion-v1-5",
        "variant": "fp16",
        "revision": "main",
    }
},
```

Model defines the pretrained base model for fine tuning.

The argument `name` defines the name of pretrained base model.

The mode name could be the original Stable Diffusion models, such as the Stable Diffusion 1.5 and the Stable Diffusion XL, or a checkpoint that is fine-tuned based on the original Stable Diffusion models.

The model name should be a Huggingface model ID.

The argument `variant` means the model dtype variant, can be null (no variant), fp16 (float16), bf16 (bfloat16). Default is `null`.

The argument `revision` means the model revision, can be main or a commit hash of the model repo. Default is `main`.

### dataset

```json
{
    "dataset": {
        "name": "lambdalabs/naruto-blip-captions",
        "url": "",
        "config_name": null,
        "image_column": "image",
        "caption_column": "text",
    }
}
```

Dataset defines the dataset to train on.

The `name` argument specifies the dataset to train on. You can provide either a Hugging Face dataset ID or a local file path to a dataset on your filesystem.

The `url` argument specifies the URL of a dataset file to download. The file can be compressed (in formats like .zip, .tar, .tar.gz, etc.) and will be automatically extracted. The downloaded file will then be loaded using the Hugging Face dataset library.

If both `name` and `url` are provided, only the `name` argument will be used. You must specify either `name` or `url` (but not necessarily both).

The argument `config_name` defines the config file name of the dataset, leave as null if there is only one config. Default is `null`.

The argument `image_column` defines the column of the dataset containing an image. Default is `"image"`.

The argument `caption_column` defines the column of the dataset containing a caption. Default is `"text"`.

### validation

```json
{
    "validation": {
        "prompt": null,
        "num_images": 4
    }
}
```

Validation defines the prompt for the validation inference.

The argument `prompt` defines the prompt for the validation inference. It should be a string or null. When `prompt` is null, we will random select `num_images` prompt from the dataset for inference.

### train\_args

```json
"train_args": {
    "learning_rate": 1e-4,
    "batch_size": 1,
    "gradient_accumulation_steps": 4,
    "num_train_steps": 100,
    "max_train_steps": 15000,
    "scale_lr": true,
    "resolution": 512,
    "noise_offset": 0,
    "lr_scheduler": {
        "lr_scheduler": "cosine",
        "lr_warmup_steps": 500,
    },
    "adam_args": {
        "beta1": 0.9,
        "beta2": 0.999,
        "weight_decay": 0.01,
        "epsilon": 1e-8
    }
}
```

Train args defines the arguments for training.

The argument `learning_rate` defines the initial learning rate (after potentail warmup period) to use.

The argument `batch_size` defines the batch size for training dataloader.

The argument `gradient_accumulation_steps` defines the number of updates steps to accumulate before performing a backward/update pass.

The argument `prediction_type` defines the prediction\_type that shall be used for training. Choose between 'epsilon' or 'v\_prediction' or leave `None`. If left to `None` the default prediction type of the scheduler: `noise_scheduler.config.prediction_type` is chosen.

The argument `max_grad_norm` defines the max gradient norm for clipping gradient norm in training.

Usually the training progress will take a long time to complete. We cannot run the whole training progress in one task, because each task has a max execution time limit in the crynux network, and the time limit is too short to complete the whole training progress. So we need to split the whole training progress into serveral tasks, each task runs only a few steps of the training progress and save its result. The next task will use the previous task result as its base model to continue the training. This progress will repeat until the whole training is completed. We use arguments `num_train_epochs` or `num_train_steps` to define the epochs or updates steps performed in one task, and arguments `max_train_epochs` or `max_train_steps` to define the epochs or updates steps the whole training progress takes. If `num_train_steps` and `max_train_steps` are provided, they will overrided `num_train_epochs` and `max_train_epochs`, respectively.

The argument `scale_lr` defines the whether to scale the learning rate by number of GPUs, gradient accumulation steps and batch size. Default is true.

The argument `resolution` defines the resolution for the input images. All the images in the train/validation dataset will be resize to this resolution.

The argument `noise_offset` defines the scale of noise offset.

The argument `snr_gamma` defines the SNR weighting gamma to be used if rebalancing the loss. Recommended value is 5.0. Default is null, means not to rebalance the loss.

#### lr\_scheduler

```json
"lr_scheduler": {
    "lr_scheduler": "cosine",
    "lr_warmup_steps": 500,
}
```

The argument `lr_scheduler` defines the learning rate scheduler type to use. Choose between \["linear", "cosine", "cosine\_with\_restarts", "polynomial", "constant", "constant\_with\_warmup"].

The argument `lr_warmup_steps` defines the number of steps for the warmup in the lr scheduler.

#### adam\_args

```json
"adam_args": {
    "beta1": 0.9,
    "beta2": 0.999,
    "weight_decay": 0.01,
    "epsilon": 1e-8
}
```

The argument `adam_args` defines parameters for the Adam optimizer.

The argument `beta1` defines the beta1 parameter for the Adam optimizer.

The argument `beta2` defines the beta2 parameter for the Adam optimizer.

The argument `weight_decay` defines the weight decay to use.

The argument `epsilon` defines the epsilon value for the Adam optimizer.

### lora

```json
"lora": {
    "rank": 4,
    "init_lora_weights": "gaussian",
    "target_modules": ["to_k", "to_q", "to_v", "to_out.0"]
}
```

Lora defines arguments for the lora layers.

The argument `rank` defines the dimension of the LoRA attention.

The argument `init_lora_weights` defines how to initialize the weights of the adapter layers. Can be a boolean or choose between \["gaussian", "loftq"]. Passing True (default) results in the default initialization from the reference implementation from Microsoft. Passing ‘gaussian’ results in Gaussian initialization scaled by the LoRA rank for linear and layers. Setting the initialization to False leads to completely random initialization and is discouraged. Pass 'loftq' to use LoftQ initialization.

The argument `target_modules` defines the names of the modules to apply the adapter to. If this is specified, only the modules with the specified names will be replaced. When passing a string, a regex match will be performed.

### transforms

```json
"transforms": {
    "center_crop": true,
    "random_flip": true,
}
```

Transforms defines the tranform operations applied to the image before training.

The argument `center_crop` defines whether to center crop the input images to the resolution. If not set, the images will be randomly cropped. The images will be resized to the resolution first before cropping.

The argument `random_flip` defines whether to randomly flip images horizontally.

### dataloader\_num\_workers

The argument `dataloader_num_workers` defines the number of subprocesses to use for data loading. 0 means that the data will be loaded in the main process.

### mixed\_precision

The argument `mixed_precision` defines whether to use mixed precision in training. Choose between fp16 and bf16 (bfloat16). Bf16 requires PyTorch >=1.10 and an Nvidia Ampere GPU. No means to disable the mixed precision.

### seed

The argument `seed` defines the seed used to initialize the random processes.

{% hint style="info" %}
Helium Network requires a deterministic algorithm for text generation, which means the text generated on the different nodes of the same deivces, given the same task definition, should be the same. This is a requirement for the consensus protocol to work. The seed is left as a required argument in the task definition so that all the nodes could use the same seed to initialize their random number generators, which will hopefully produce the same random numbers across all the nodes.

Beside the seed, the GPT Task Framework has been implemented to maximize the reproducibility.
{% endhint %}

### checkpoint

The argument `checkpoint` defines whether this task should be resumed from a previous checkpoint. It should be a directory containing the checkpoint files in your local file system. If the task is executed in the Hydrogen Network, this parameter will be injected automatically if the checkpoint is provided.

## Fine tuning Task Response

The fine tuning task response are two directories `checkpoint` and `validation`, stores the checkpoint files and validation result images, respectively.

The checkpoint files can be used as the final lora weights, or as the checkpoint the next task to be resumed from. The validation result images can be used to check the model quality.

When executing the fine tuning task, you need to pass an argument `output_dir` to specify where the `checkpoint` and `validation` directories will be stored. If the task is executed in the Hydrogen Network, the `output_dir` parameter will be injected automatically.
