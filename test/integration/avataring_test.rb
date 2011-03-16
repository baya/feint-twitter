
require 'test_helper'

class AvataringTest < ActionController::IntegrationTest

  def setup
    @nancy = Factory(:user, :username => "nancy")
    clear_files_of(@nancy)
  end

  test "user upload a valid image, will has three images origin, 58X58>, 140X140>" do
    image_path = File.join(*[Rails.root.to_s, "public", "images", "rails.png"])
    image_size = File.size(image_path)
    assert @nancy.avatar_options[:size].include?(image_size)
    upload_avatar_step(@nancy, "rails.png")
    assert File.exist?(@nancy.diskfile_path(:origin))
    assert File.exist?(@nancy.diskfile_path(:thumb))
    assert File.exist?(@nancy.diskfile_path(:medium))
    assert @nancy.avatar_url(:style => "thumb") =~ /thumb/
    assert @nancy.avatar_url(:style => "medium") =~ /medium/
  end

  test "user upload a too large image, will fail" do
    image_path = File.join(*[Rails.root.to_s, "public", "images", "tree.jpg"])
    image_size = File.size(image_path)
    assert image_size > @nancy.avatar_options[:max_size]
    upload_avatar_step(@nancy, "tree.jpg")
    assert !File.exist?(@nancy.diskfile_path(:origin))
    assert !File.exist?(@nancy.diskfile_path(:thumb))
    assert !File.exist?(@nancy.diskfile_path(:medium))
    assert !(@nancy.avatar_url(:style => "thumb") =~ /thumb/)
    assert !(@nancy.avatar_url(:style => "medium") =~ /medium/)
  end

  test "user upload a invalid format image, will fail" do
    image_path = File.join(*[Rails.root.to_s, "public", "images", "invalid.txt"])
    upload_avatar_step(@nancy, "invalid.txt")
    assert !File.exist?(@nancy.diskfile_path(:origin))
    assert !File.exist?(@nancy.diskfile_path(:thumb))
    assert !File.exist?(@nancy.diskfile_path(:medium))
    assert !(@nancy.avatar_url(:style => "thumb") =~ /thumb/)
    assert !(@nancy.avatar_url(:style => "medium") =~ /medium/)
  end

  def clear_files_of(user)
    File.delete(user.diskfile_path(:origin)) if File.exist?(user.diskfile_path(:origin))
    File.delete(user.diskfile_path(:thumb)) if File.exist?(user.diskfile_path(:thumb))
    File.delete(user.diskfile_path(:medium)) if File.exist?(user.diskfile_path(:medium))
  end

end
