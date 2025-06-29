class Cliente < ApplicationRecord
  self.table_name = "Cliente"
  has_many :facturas, dependent: :destroy
end