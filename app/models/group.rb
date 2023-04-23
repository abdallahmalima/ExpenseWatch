class Group < ApplicationRecord
  belongs_to :user, foreign_key: 'author_id'
  has_many :group_dealings, foreign_key: 'group_id'
  has_many :dealings, through: :group_dealings
  has_one_attached :icon

  validates :name, presence: true

  attr_accessor :icon_file # This is a virtual attribute that we will use to hold the uploaded file temporarily

  def save_icon_file
    # This method will save the uploaded file to disk and set the icon_path attribute
    return unless icon_file.present?

    file_name = "#{SecureRandom.uuid}-#{icon_file.original_filename}"
    path = File.join(Rails.root, 'public', 'icons', file_name)
    File.binwrite(path, icon_file.read)
    self.icon_path = "/icons/#{file_name}"
  end
end
