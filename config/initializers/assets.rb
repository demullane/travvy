# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( home.js )
Rails.application.config.assets.precompile += %w( results.js )
Rails.application.config.assets.precompile += %w( jquery.geocomplete.js )
Rails.application.config.assets.precompile += %w( jquery.validate.additional-methods.js )
Rails.application.config.assets.precompile += %w( jquery.validate.js )
Rails.application.config.assets.precompile += %w( pinterest_grid.js )
