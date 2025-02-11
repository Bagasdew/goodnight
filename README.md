# README

This App is an API to create and get simple Family Tree

## Prerequisite
- Rails 7
- Postgresql 16 (lower version works too)

## How to Setup
1. pull this repo
2. run `bundle install` to install the gems
3. copy the `env.example` file, rename it into `.env` and setup your database connection accordingly (no need to create the database for now)
4. run `rake db:setup`, this will create your database, run the migrations, and seed the data
5. in terminal, run `rails s` and you can access the API via `localhost:3000`

## How to Use and Test
This api have 5 endpoints:
- `user/index` -> to get all following users clock in data from past week
- `user/clock_in` -> to clock in specified user
- `user/clock_out` -> to clock out specified user
- `user/follow` -> to follow a user
- `user/unfollow` -> to unfollow a user

each usage can be found in rspec files. Specifically in `user_controller_spec.rb` file
To run test, run this line `bundle exec rspec spec/requests/user_controller_spec.rb -fd`

## Few Things to Note
1. This is a rails generated project from console, so there will be a few of unused files that is included, I apologize for the mess
2. Should you have questions, feel free to reach out to me!
