class HomeController < ApplicationController
  def index
  end

  def test
    render json: { message: 'Hello, World!' }
  end

  def sample
    @zz = 'Hello, World!'
  end
end
