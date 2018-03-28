# Mendeley API changes watcher

Periodically fetch Mendeley API documentation at 
https://api.mendeley.com/apidocs/docs and store for easy change tracking.

## Install

Create app on Heroku account:

```bash
heroku create your-app
```

and add it as a remote. Then deploy:

```bash
git push heroku master
```

Add private key of a user which is able to commit to this repo.

```bash
heroku config:add PRIVATE_KEY="$(cat dummy-id-rsa)"
```

Add scheduler that will be invoking fetching:

```bash
heroku addons:create scheduler:standard
heroku addons:open scheduler
```

and enter `./fetch.sh`.

