class DetalleFactura < ApplicationRecord
  self.table_name = "DetalleFactura"
  belongs_to :factura
  belongs_to :producto
  has_many :detalle_factura_impuestos, dependent: :destroy
end