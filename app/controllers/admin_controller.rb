class AdminController < ApplicationController
  # ================ Manejo de Stocks =================#
  def stock
    productos = ActiveRecord::Base.connection.execute("SELECT * FROM Producto")
    @productos = productos.to_a
    @productos.each do |producto|
      producto['id'] = producto['Id'].to_i
      producto['nombre'] = producto['Nombre']
      producto['precio'] = producto['Precio'].to_f
      producto['existencia'] = producto['Stock'].to_i
    end

    @productos.each do |producto|
      if producto['existencia'] <= 10
        flash.now[:alert] = "Stock bajo"
        break
      end
    end
  end

  def comprar_stock
    producto = Producto.find(params[:id])
    cantidad = params[:cantidad].to_i
    producto.Stock += cantidad
    producto.save
    redirect_to admin_stock_path
  end

  def crear_producto
    Producto.create(
      Nombre: params[:nombre],
      Precio: params[:precio],
      Stock: params[:stock]
    )
    redirect_to admin_stock_path
  end

  def cambiar_impuesto
    producto = ActiveRecord::Base.connection.execute("SELECT * FROM Producto WHERE Id = #{params[:id]}").first
    @producto = {
      'Id' => producto['Id'].to_i,
      'Nombre' => producto['Nombre']
    }
    
    @impuestos = ActiveRecord::Base.connection.execute("SELECT * FROM Impuesto").to_a
    @impuestos_producto = ActiveRecord::Base.connection.execute(
      "SELECT IdImpuesto 
      FROM ProductoImpuesto 
      WHERE IdProducto = #{params[:id]}"
    ).map { |ip| ip['IdImpuesto'] }
  end

  def agregar_impuesto
    ActiveRecord::Base.connection.execute(
      "INSERT INTO ProductoImpuesto (IdProducto, IdImpuesto) 
      VALUES (#{params[:id_producto]}, #{params[:id_impuesto]})"
    )
    redirect_to admin_cambiar_impuesto_path(params[:id_producto])
  end

  def eliminar_impuesto
    ActiveRecord::Base.connection.execute(
      "DELETE FROM ProductoImpuesto 
      WHERE IdProducto = #{params[:id_producto]} 
      AND IdImpuesto = #{params[:id_impuesto]}"
    )
    redirect_to admin_cambiar_impuesto_path(params[:id_producto])
  end

    # ================ Movimientos de Stock =================#
  def movimientos_stock
    movimientos = ActiveRecord::Base.connection.execute("
      SELECT 
        P.Nombre
        , MS.Tipo
        , MS.Cantidad
        , MS.Nota
        , MS.Fecha
      FROM MovimientoStock MS
      INNER JOIN Producto P ON MS.IdProducto = P.Id"
    )
    @movimientos = movimientos.to_a
  end
  
  # ================ Manejo de Impuestos =================#
  def impuesto
    @impuestos = ActiveRecord::Base.connection.execute("SELECT * FROM Impuesto").to_a
  end

  def crear_impuesto
    ActiveRecord::Base.connection.execute(
      "INSERT INTO Impuesto (Nombre, Porcentaje) 
      VALUES ('#{params[:nombre]}', #{params[:porcentaje]})"
    )
    redirect_to admin_impuesto_path
  end

  def actualizar_impuesto
    ActiveRecord::Base.connection.execute(
      "UPDATE Impuesto 
      SET Nombre = '#{params[:nombre]}'
      , Porcentaje = #{params[:porcentaje]} 
      WHERE Id = #{params[:id]}"
    )
    redirect_to admin_impuesto_path
  end

  def editar_impuesto
    if params[:id] == "new"
      redirect_to admin_impuesto_path
    else
      @impuesto = ActiveRecord::Base.connection.execute("SELECT * FROM Impuesto WHERE Id = #{params[:id]}").first
      render 'editar_impuesto_form'
    end
  end
  
    # ================ Manejo de Sesion =================#
  def require_admin
    unless session[:admin_username]
      redirect_to admin_login_form_path
    end
  end
end
