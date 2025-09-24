# Proxy Settings

Sometimes a proxy is required to access Huggingface and Civitai in your network environment. Crynux Node supports to specify the proxy in the config file.

## Locate the config file

{% tabs %}
{% tab title="Windows" %}
Go to the directory where you click `Crynux Node.exe`, there is a sub directory with name `config`, the config file can be found inside with name `config.yml`.
{% endtab %}

{% tab title="Mac" %}
The config folder of the Mac app locates inside your home diretory at:

`~/Library/Application\ Support/crynux.io/Crynux\ Node/`

To access this folder, open a terminal window and type in the following command:

`$ open ~/Library/Application\ Support/crynux.io/Crynux\ Node/`

And the `config.yml` is located inside under the `config` folder.
{% endtab %}

{% tab title="Docker" %}
**If you have mounted the config directory outside of the container**

find the config file `config.yml` in the mounted config directory on the host machine. Which should be `config` folder inside the project root, if you have followed the tutorial [Start a Node - Docker](start-a-node/start-a-node-docker.md).

**If you have not mounted the config directory**

the config file can be found inside the container as `/app/config/config.yml`.
{% endtab %}

{% tab title="Linux" %}
If you downloaded the binary release version of Linux server, the config file `config.yml` can be found in the `config` folder of the project root.
{% endtab %}

{% tab title="Source Code" %}
The config file is located at `config/config.yml`, relative to the project root folder.
{% endtab %}
{% endtabs %}

## Fill in the proxy settings

Open the `config.yml` file with a text editor, and find the section below:

```
---
task_config:
  proxy:
    host: ''
    password: ''
    port: 8080
    username: ''
```

Just fill in the fields according to your proxy settings, and restart the node.

If your proxy requires authentication, fill in the `username` and `password` fields accordingly, otherwise just leave the fields empty.

If the `host` is not set, the node will try to use the proxy settings in the environment variables, which will be the value given in `HTTPS_PROXY`. No proxy will be used if this environment variable is not set.

Below is an example of using a proxy at localhost, with no proxy authentication:

```
---
task_config:
  proxy:
    host: 'http://127.0.0.1'
    password: ''
    port: 33210
    username: ''
```
