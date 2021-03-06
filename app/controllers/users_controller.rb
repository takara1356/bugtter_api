class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]
  before_action :authenticate!
  skip_before_action :authenticate!, only: [ :create, :sign_in ]

  # GET /users
  def index
    users = User.all

    render json: users, only:[:id, :name]
  end

  # GET /users/1
  def show
    user = User.find(params[:id])
    render json: user, only:[:id, :name]
  end

  # POST /users
  def create
    user = User.new(name: params[:name], email: params[:email], password: params[:password])

    if user.save
      render json: user
    else
      render json: { errors: user.errors.full_messages }, status: 400
    end
  end

  # PATCH/PUT /users/1
  def update
    if user.update(user_params)
      render json: user
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    user.destroy
  end

  def sign_in
    # find_byはID以外の条件から検索できるメソッド
    user = User.find_by(email: params[:email])

    if user && user.authenticate(params[:password])
      render json: user, only:[:id, :name, :email, :token]
    else
      render json: { errors: ['ログインに失敗しました'] }, status: 401
    end
  end

  def me
    render json: current_user
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:name, :email, :password, :token)
    end

    def authenticate!
      authenticate_or_request_with_http_token do |token, options|
        auth_user = User.find_by(token: token)
        auth_user != nil ? true : false
      end
    end
  
    def current_user
      current_user ||= User.find_by(token: request.headers['Authorization'].split[1])
    end
end
