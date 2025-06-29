Rails.application.routes.draw do
  # Root route
  root "login#home"

  # Login routes
  get "login/admin", to: "login#admin", as: :admin_login_form
  post "login/admin", to: "login#login_admin", as: :login_admin

  get "login/cliente", to: "login#cliente", as: :cliente_login_form
  post "login/cliente", to: "login#login_cliente", as: :login_cliente

  get '/login/nuevo', to: 'login#nuevo', as: :nuevo_cliente
  get '/login/crear_cliente', to: 'login#crear_cliente'
  post '/login/crear_cliente', to: 'login#crear_cliente', as: :crear_cliente

  delete "logout", to: "login#logout", as: :logout

  # Admin dashboard and additional routes
  get "admin/home", to: "admin#home", as: :admin_home
  
  get "admin/movimientos_stock", to: "admin#movimientos_stock", as: :admin_movimientos_stock
  get "admin/stock", to: "admin#stock", as: :admin_stock
  get "admin/impuesto", to: "admin#impuesto", as: :admin_impuesto
  post "admin/comprar_stock", to: "admin#comprar_stock"
  post "admin/crear_producto", to: "admin#crear_producto"

  get "admin/cambiar_impuesto/:id", to: "admin#cambiar_impuesto", as: :admin_cambiar_impuesto
  post "admin/agregar_impuesto", to: "admin#agregar_impuesto"
  post "admin/eliminar_impuesto", to: "admin#eliminar_impuesto"

  post "admin/crear_impuesto", to: "admin#crear_impuesto"
  post "admin/actualizar_impuesto/:id", to: "admin#actualizar_impuesto", as: :admin_actualizar_impuesto
  get "admin/editar_impuesto/:id", to: "admin#editar_impuesto", as: :admin_editar_impuesto

  # Cliente dashboard and additional routes
  get "cliente/home", to: "cliente#home", as: :cliente_home
  
  get "cliente/factura", to: "cliente#factura", as: :cliente_factura
  get "cliente/impuestoComprar", to: "cliente#impuestoComprar", as: :cliente_impuesto_comprar
  post "cliente/comprar_producto", to: "cliente#comprar_producto", as: :cliente_comprar_producto
  post "cliente/terminar_compra", to: "cliente#terminar_compra", as: :cliente_terminar_compra
  post "cliente/limpiar_carrito", to: "cliente#limpiar_carrito", as: :limpiar_carrito
  get "cliente/ver_factura", to: "cliente#ver_factura", as: :ver_factura
end
