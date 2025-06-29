class MovimientoStock < ApplicationRecord
  self.table_name = "MovimientoStock"
  belongs_to :producto
  validates :tipo, inclusion: { in: ['Entrada', 'Salida'] }
end