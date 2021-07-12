class Product < ApplicationRecord
    has_one :promotion
    has_one_attached :image_prod
end
