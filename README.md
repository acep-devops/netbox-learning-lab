# NetBox Docker Stack (GitOps)

A self-hosted NetBox deployment tailored for Portainer, pre-packaged with the netbox-topology-views plugin. This repository stores the Infrastructure as Code (IaC) and Configuration as Code (CaC), while sensitive data like passwords remain securely isolated in Portainer.

## Repository Contents

* **`docker-compose.yml`**: (IaC) The main infrastructure configuration that defines the NetBox, PostgreSQL, and Redis containers.
* **`Dockerfile`**: (CaC) Instructions for Portainer to build a custom NetBox image that includes the topology plugin.
* **`plugin_requirements.txt`**: Specifies the exact version of the Topology plugin to install during the build process.

## Deployment Instructions (Portainer)

1. Open your Portainer dashboard and navigate to **Stacks** > **Add stack**.
2. Select the **Repository** option and paste the URL to this Git repository.
3. Scroll down to **Environment variables** and define your secure credentials:
* `DB_NAME` *(e.g., netbox)*
* `DB_USER` *(e.g., netbox)*
* `DB_PASSWORD` *(Your secure database password)*
* `NETBOX_SECRET` *(A random string of at least 50 characters)*


4. Click **Deploy the stack**. Portainer will pull the code, build the custom image, inject the passwords, and launch NetBox.

## Accessing the Web Interface

Due to firewall restrictions, NetBox is securely accessed via a local SSH tunnel.

Run this command in your local workstation terminal, leaving the window open:

```cmd
ssh -L 8888:localhost:8888 user@<YOUR_SERVER_IP>

```

Navigate to **`http://localhost:8888`** in your local web browser and log in with your admin credentials.
