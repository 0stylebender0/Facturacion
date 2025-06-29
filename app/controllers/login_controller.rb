class LoginController < ApplicationController
  def login_admin
      username = params[:username]
      password = params[:password]

      result = ActiveRecord::Base.connection.execute(
        "Declare @IsValid BIT;" + 
        "EXEC sp_LoginAdmin @UserName = '#{username}', @Pwd = '#{password}', @IsValid = @IsValid OUTPUT;" +
        "SELECT @IsValid AS is_valid;"
      )

      is_valid = result.first['is_valid']
      if is_valid
        session[:admin_username] = username
        redirect_to admin_home_path, notice: "Inicio de sesión exitoso como administrador."
      else
        flash.now[:alert] = "Credenciales inválidas. Por favor, inténtelo de nuevo."
        render :admin
      end
  end

def login_cliente
    correo = params[:correo]
    password = params[:password]

    result = ActiveRecord::Base.connection.execute(
      "DECLARE @IdCliente INT; " +
      "EXEC sp_LoginCliente @Correo = '#{correo}', @Pwd = '#{password}', @IdCliente = @IdCliente OUTPUT; " +
      "SELECT @IdCliente AS id_cliente;"
    )

    id_cliente = result.first['id_cliente']

    if id_cliente > 0
      session[:cliente_id] = id_cliente
      redirect_to cliente_home_path, notice: '¡Inicio de sesión exitoso como cliente!'
    else
      flash.now[:alert] = 'Correo o contraseña incorrectos'
      render :cliente
    end
  end

  def crear_cliente
    nombre = params[:nombre]
    correo = params[:correo]
    telefono = params[:telefono]
    password = params[:password]

    result = ActiveRecord::Base.connection.execute(
      "DECLARE @Success BIT; " +
      "EXEC sp_RegistrarCliente 
        @Nombre = '#{nombre}'
        , @Correo = '#{correo}'
        , @Telefono = '#{telefono}'
        , @Pwd = '#{password}'
        , @Success = @Success OUTPUT; " +
      "SELECT @Success AS success;"
    )

    success = result.first['success']
    if success
      redirect_to login_cliente_path, notice: '¡Registro exitoso! Por favor, inicia sesión.'
    else
      flash.now[:alert] = 'Error al registrar. El correo ya existe o los datos son inválidos.'
    end
  end

  def logout
    session[:admin_username] = nil
    session[:cliente_id] = nil
    reset_session
    redirect_to root_path, notice: '¡Sesión cerrada exitosamente!'
  end
end
