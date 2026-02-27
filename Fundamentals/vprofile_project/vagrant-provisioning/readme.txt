## This is a VProfile Project which is a java based social media platform. There are following components in the projects:

- NGNIX -> Web Server
- Tomcat -> Application Server
- RabbitMQ -> Message Queuing Agent (Dummy Service)
- Memcache -> DB Caching
- MySQL -> DB

## The automation stacks comprises of the following:

- Vagrant -> VM Automation
- VirtualBox -> Hypervisor
- Bash -> Scripting

## Plugins

- Vagrant-hostmanager -> Simplifies multi machine vagrant setups by automatically managing the /etc/hosts file on guest VMs. Every VM on the private network knows about every other VM on the network with their designated private IPs. 
 
 Enable the following settings:

  - config.hostmanager.enabled = true : enables the host manager for a VM stack
  - config.hostmanager.manage_host = true : Updates the /etc/hosts and C:\Windows\System32\drivers\etc\hosts file on host and guest
