class DetalleFacturaImpuesto < ApplicationRecord
  self.table_name = "DetalleFacturaImpuesto"
  belongs_to :detalle_factura
  belongs_to :impuesto
end