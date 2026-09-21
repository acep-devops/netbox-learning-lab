This `docker-compose.yml` file defines a **microservices architecture**. Instead of installing everything on a single operating system, Docker breaks NetBox down into six highly specialized, isolated containers that talk to each other over an internal virtual network.

## 1. The Data Layer

These three containers handle storage, queuing, and performance.

* **`postgres`**: The core relational database. Every site, VLAN, Proxmox host, and cable you create in NetBox is saved here as strict, structured data.
* **`redis`**: An in-memory data store. NetBox employs Redis specifically to manage the queue for background tasks, like bulk-importing devices or firing webhooks to other systems.
* **`redis-cache`**: A separate Redis instance dedicated purely to caching frequent database queries so the web interface loads faster. Keeping this separate from the main `redis` container ensures that flushing the cache doesn't accidentally delete pending background tasks.

## 2. The Application Layer

These three containers run the actual NetBox Python application, but each has a distinct job.

https://github.com/netbox-community/netbox

* **`netbox`**: The main web server (running Gunicorn) that serves the user interface and the API. Notice the `build:` block—instead of pulling the standard pre-built image, it tells Portainer to look at your `Dockerfile`, install the Topology plugin, and run *that* custom image. It exposes internal port `8080` to your external port `8888`.
* **`netbox-worker`**: A background processor. If you tell NetBox to run a massive data-sync script or report, doing it in the main container would freeze the web interface for everyone else. Instead, the main container hands the job to the `redis` queue, and this container executes it asynchronously using `rqworker`.
* **`netbox-housekeeping`**: A maintenance container. It routinely runs the `housekeeping.sh` script to clear out expired user sessions, clean up stale records, and prune old logs so the database doesn't bloat over time.

## 3. The Connective Tissue

To make these six isolated containers act as one cohesive system, Docker uses a few tricks:

* **Environment Variables**: You are telling the NetBox containers exactly how to find the databases (`DB_HOST=postgres`, `REDIS_HOST=redis`) and injecting passwords securely from Portainer (`${DB_PASSWORD}`). Because all these containers share the same Compose file, Docker automatically resolves the service names (like `postgres`) to the correct internal IP addresses.
* **`depends_on`**: This enforces the boot order. NetBox will immediately crash if it boots before the database is ready. These blocks tell Docker: *"Do not start NetBox, Worker, or Housekeeping until Postgres and Redis are fully online."*

## 4. The Storage Layer (Volumes)

By default, Docker containers are amnesiac—if you reboot them, any file saved inside is permanently destroyed.

The `volumes:` block at the very bottom creates permanent, safe folders on your actual Ubuntu VM's hard drive and mounts them *into* the containers.

* `netbox-postgres-data` ensures your actual network database survives container reboots.
* `netbox-media-files` safely stores user-uploaded files, like custom logos or rack elevation photos.
* `netbox-reports-files` and `netbox-scripts-files` store custom Python code you might write later to validate your data or automate tasks.
