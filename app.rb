# frozen_string_literal: true

require 'rubygems'
require 'sinatra'
require './lib/utility'

set :environment, :development #:production
set :logging, true
set :show_exceptions, false
set :run, false
enable :sessions


get '/' do
  task = load_task
  if task.empty?
    task = RegexpTask.new.raw
    session[:task] = task
    session[:attempts] = 0
    task = Regexp.compile('\A'+task+'\Z')
  end
  @examples = generate_samples(task, /\A.*\Z/, 3)
  erb :index, layout: :main
end

get '/reset' do
  session[:task] = RegexpTask.new.raw
  session[:attempts] = 0
  redirect '/'
end

post '/' do
  task = load_task
  return redirect('/') if task.empty?
  user_regexp = Regexp.compile('\A'+params[:regexp]+'\Z')
  @examples = generate_samples(task, user_regexp, 1)
  if @examples.empty?
    [200, {status:'Success'}]
  else
    session[:attempts] += 1
    [200, {example: @examples[0][0],
           hidden_variant: @examples[0][1]}.to_json]
  end
end

private

def load_task
  task = session[:task]
  task && Regexp.compile('\A'+task+'\Z')
end

def generate_samples(task_regexp, user_regexp, size)
  examples  = []
  size.times do
    variant = RegexpTask.find_different(task_regexp, user_regexp)
    examples << [variant, (task_regexp =~ variant) == 0 ]
  end
  examples.compact
end
