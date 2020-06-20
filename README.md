# tw-megaphone

## How it works
1. Twitter login
2. Sync your follower (5000 followers per 15min)
3. Decide ranking storategy
4. Send DMs (1000 per day)

## Setup instruction
### running locally
Requirement: Ruby (tested on Ruby 2.7.1)

Create Twitter app from https://developer.twitter.com/en/apps 
Enable signin with twitter and DM permission
Create .env file with `API_KEY` and `API_SECRET`

```
bundle install
rake db:migrate
rails s
```

### deploying on heroku
TODO
