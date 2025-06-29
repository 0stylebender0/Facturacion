class Factura < ApplicationRecord
  self.table_name = "Factura"
  belongs_to :cliente
  has_many :detalle_facturas, dependent: :destroy
end