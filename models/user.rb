class User < ActiveRecord::Base
  validates_uniqueness_of :name, :email

  def to_json
    super(except: :password)
    # 'super' calls a parent method of the same name,
    # with the same arguments.

  end

end