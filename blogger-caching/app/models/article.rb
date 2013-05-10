class Article < ActiveRecord::Base
  attr_accessible :title, :body, :tag_list
  validates :title, :body, presence: true

  has_many :comments, dependent: :destroy

  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings

  after_save :clear_cache
  after_destroy :clear_cache

  def clear_cache
    Rails.cache.delete('articles-all')
  end

  def self.all_cached
    Rails.cache.fetch("articles-all",expires_in: 15.minutes) do
      Article.all
    end
  end

  def tag_list
    tags.collect { |tag| tag.name }.join(", ")
  end

  def tag_list=(value)
    tag_names = tag_list_to_tag_names(value)
    found_tags = tag_names.map { |name| Tag.find_or_create_by_name name }
    self.tags = found_tags
  end

  def tag_list_to_tag_names(value)
    value.to_s.split(",").map {|name| name.strip.downcase }.uniq
  end

end
