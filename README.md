The goal of this project is to provide an easily-installable (via deb package) and ultra-thin apt repo for deb packages that are hosted remotely in GitHub releases.

```
echo "deb [arch=all] http://philbot.eu:8000/ stable main" | sudo tee /etc/apt/sources.list.d/example.list
sudo apt-get update --allow-insecure-repositories
sudo apt-get install gitaptly
```

edit `/etc/gitaptly.conf` by adding new github repos to pull debian packages from. 
