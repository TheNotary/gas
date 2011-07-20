module Gas

  # Class that keeps track of users
  class Configuration
    attr_reader :users

    # Parses [User]s from a string of the config file
    # @param [String] config The configuration file
    # @return [Configuration]
    def self.parse(config)
      users = []
      config.scan(/\[(.+)\]\s+name = (.+)\s+email = (.+)/) do |nickname, name, email|
        users << User.new(name, email, nickname)
      end

      Configuration.new users
    end

    # Can parse out the current user from the gitconfig
    # @param [String] gitconfig The git configuration
    # @return [User] The current user
    def self.current_user(gitconfig)
      User.parse gitconfig
    end

    # Checks if a user with _nickname_ exists
    # @param [String] nickname
    # @return [Boolean]
    def exists?(nickname)
      @users.each do |user|
        if user.nickname == nickname
          return true;
        end
      end

      false
    end

    # Returns the user with nickname nil if no such user exists
    # @param [String|Symbol] nickname
    # @return [User|nil]
    def get(nickname)
      @users.each do |user|
        if user.nickname == nickname.to_s
          return user
        end
      end

      nil
    end

    # Override [] to get hash style acces to users
    # @param [String|Symbol] nickname
    # @return [User|nil]
    def [](nickname)
      get nickname
    end

    # Adds a user
    # @param [User]
    def add(user)
      @users << user
    end

    # Deletes a user by nickname
    # @param [String] nickname The nickname of the user to delete
    def delete(nickname)
      @users.delete_if do |user|
        user.nickname == nickname
      end
    end

    # @param [Array<User>] users
    def initialize(users)
      @users = users
    end

    # Override to_s to output correct format
    def to_s
      @users.join("\n")
    end

  end
end
