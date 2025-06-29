class Producto < ApplicationRecord
  self.table_name = "Producto"
  has_many :movimiento_stocks, dependent: :destroy
  has_many :detalle_facturas, dependent: :destroy
end