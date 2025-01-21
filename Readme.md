# Install in a Ubuntu Container

1. ssh in as `root`, and run this command:

```sh
curl -fsSL https://raw.githubusercontent.com/jroes/dotfiles/main/setup/setup_bootstrap.bash | bash
```

2. ssh in, this time as `jroes`, and run the same command.

3. copy over the OpenAI key as follows:

```sh
scp <oldhost>:.config/nvim/chatgpt_nvim.txt <newhost>:.config/nvim/chatgpt_nvim.txt
```

## (Optional) install bacon

1. Install `bacon` (the new `cargo-watch`)

```sh
cargo install --locked bacon
```

See [the website](https://dystroy.org/bacon/).

# Multipass setup instructions

Run these commands:

```sh
INSTANCE_NAME=test-4 # or whatever
multipass launch --cpus $(sysctl -n hw.physicalcpu) --disk 50G --memory $(echo "scale=1; $(sysctl -n hw.memsize) / 4 / 1073741824" | bc)G --name ${INSTANCE_NAME}
multipass exec ${INSTANCE_NAME} -- sh -c "echo '$(cat ~/.ssh/id_ed25519.pub)' >> /home/ubuntu/.ssh/authorized_keys"
multipass info ${INSTANCE_NAME}
```

Then update `.ssh/config` and run:

```sh
ssh <instance-name>
```

# Blink Shell Installation Instructions

Make sure the following settings are set for your host:

### Blink SSH

* **HostName**: *(Ip address of the host)*
* **Port**: `22`
* **User**: `root`*(update to username later in process)*
* **Key**: `Blink3@Elbowpads`
* **SSH Config**: 
```
Compression yes
LocalForward 8501 localhost:8501
ForwardAgent yes
```
* SSH Agent
    * **Agent Forwarding**: `Always`
    * **Forward Keys**: `Blink3@Elbowpads`

### MacBook SSH

Make sure your SSH config has the following structure:

```
Host <HOST>
     HostName <IP ADDRESS>
     Port 22
     User jroes
     ForwardAgent yes
     AddKeysToAgent yes
     IdentitiesOnly yes
     IdentityFile ~/.ssh/id_ed25519
     LocalForward 8501 <IP ADDRESS>:8501
     LocalForward 4867 <IP ADDRESS>:4867
```
