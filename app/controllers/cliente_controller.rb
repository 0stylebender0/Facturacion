class ClienteController < ApplicationController
  def home
    session[:carrito] ||= []
  end

  def terminar_compra
    carrito = session[:carrito] || []
    if carrito.empty?
      redirect_to cliente_factura_path
    end
    cliente_id = session[:cliente_id]
    unless cliente_id
      redirect_to cliente_login_form_path
    end

    detalles = carrito.map do |item|
      "(#{item['id'] || item[:id]}, #{item['cantidad'] || item[:cantidad]})"
    end.join(',')

    sql = <<-SQL
      DECLARE @Detalles DetalleFacturaTipo;
      INSERT INTO @Detalles (IdProducto, Cantidad) VALUES #{detalles};
      DECLARE @outIdFactuta INT;
      EXEC sp_InsertarFactura
        @IdCliente = #{cliente_id},
        @Detalles = @Detalles,
        @outIdFactuta = @outIdFactuta OUTPUT;
      SELECT @outIdFactuta as IdFactura;
    SQL

    result = ActiveRecord::Base.connection.exec_query(sql)
    factura_id = result.first["IdFactura"]

    redirect_to ver_factura_path(factura_id: factura_id)
  end

  def factura
    productos = ActiveRecord::Base.connection.execute("SELECT * FROM Producto")
    @productos = productos.to_a
    @productos.each do |producto|
      producto["id"] = producto["Id"].to_i
      producto["nombre"] = producto["Nombre"]
      producto["precio"] = producto["Precio"].to_f
      producto["existencia"] = producto["Stock"].to_i
    end

    @productos.each do |producto|
      if producto['existencia'] <= 10
        flash.now[:alert] = "Stock bajo."
        break
      end
    end
  end

  def impuestoComprar
    id = params[:id].to_i
    producto = ActiveRecord::Base.connection.exec_query("SELECT * FROM Producto WHERE Id = #{id}").first
    @producto = {
      'Id' => producto['Id'].to_i,
      'Nombre' => producto['Nombre']
    }

    puts "Producto: #{@producto.inspect}"
    
    @impuestos = ActiveRecord::Base.connection.exec_query(
      "SELECT 
        I.Nombre,
        I.Porcentaje
      FROM ProductoImpuesto PIm
      JOIN Impuesto I ON I.Id = Pim.IdImpuesto
      WHERE IdProducto = #{id}"
    ).to_a

    puts "Impuestos del producto: #{@impuestos.inspect}"
  end

  def comprar_producto
    producto = Producto.find(params[:id])
    cantidad = params[:cantidad].to_i

    session[:carrito] ||= []
    existente = session[:carrito].find { |item| (item["id"] || item[:id]) == producto.Id }

    if existente
      existente["cantidad"] = cantidad if existente["cantidad"]
      existente[:cantidad] = cantidad if existente[:cantidad]
    else
      item_carrito = {
        id: producto.Id,
        nombre: producto.Nombre,
        precio: producto.Precio,
        cantidad: cantidad
      }
      session[:carrito] << item_carrito
    end

    redirect_to cliente_factura_path
  end

  def limpiar_carrito
    session[:carrito] = []
    redirect_to cliente_factura_path
  end

  def require_admin
    unless session[:cliente_id]
      redirect_to cliente_login_form_path
    end
  end

  def ver_factura
    factura_id = params[:factura_id]
    result = ActiveRecord::Base.connection.exec_query("EXEC sp_GenerarFactura #{factura_id}")
    @factura_info = result.to_a

    @factura_info_agrupada = @factura_info.group_by { |item| item['NombreProducto'] }.map do |nombre, items|
      {
        'NombreProducto' => nombre,
        'Cantidad' => items.first['Cantidad'],
        'PrecioUnitario' => items.first['PrecioUnitario'],
        'Total' => items.first['PrecioUnitario'].to_f * items.first['Cantidad'].to_f + 
                  items.sum { |i| i['Total'].to_f - (i['PrecioUnitario'].to_f * i['Cantidad'].to_f) },
        'Impuestos' => items.map { |i| i['NombreImpuesto'] }.uniq.join(', ')
      }
    end

    total_factura = ActiveRecord::Base.connection.exec_query("SELECT * FROM Factura WHERE Id = #{factura_id}").first['Total']
    @total_factura = total_factura.to_f
  end
end
