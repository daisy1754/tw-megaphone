# tw-megaphone

## How it works
1. Twitter login
2. Sync your follower (5000 followers per 15min)
3. Decide ranking storategy
4. Send DMs (1000 per day)
5. This app also provides a link for your follower to submit email address
6. Export follower data with provided emails

## Setup instruction
### running locally
Requirement: Ruby (tested on Ruby 2.7.1) and postgres.
Also needs AWS account if you want to test export feature

Create Twitter app from https://developer.twitter.com/en/apps 
 - Enable signin with twitter 
 - callback URL is `${domain}/auth/twitter/callback`. Localhost won't work - if you want to run locally you can use [ngrok](https://ngrok.com/)
 - Under permission, set DM permission

Create .env file with appropriate secrets - see .env.sample

```
bundle install
rake db:migrate
rails s
```

### deploying on heroku
https://devcenter.heroku.com/articles/getting-started-with-rails6
