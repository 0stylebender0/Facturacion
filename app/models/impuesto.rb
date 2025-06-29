class Impuesto < ApplicationRecord
  self.table_name = "Impuesto" # Nombre exacto de la tabla
  has_many :detalle_factura_impuestos, dependent: :destroy
end