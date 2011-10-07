GAS_DIRECTORY = File.expand_path('~/.gas')
SSH_DIRECTORY = File.expand_path('~/.ssh')

require 'sshkey' #external

require 'gas/version'
require 'gas/ssh'
require 'gas/user'
require 'gas/config'
require 'gas/gitconfig'


module Gas

  @config = Config.new
  @gitconfig = Gitconfig.new

  # Lists all authors
  def self.list
    puts 'Available users:'
    puts @config

    self.show
  end

  # Shows the current user
  def self.show
    user = @gitconfig.current_user

    if user
      puts 'Current user:'
      puts "#{user.name} <#{user.email}>"
      
      if Ssh.corresponding_rsa_files_exist?
        puts "This user's id_rsa key is:"
        puts `cat #{GAS_DIRECTORY}/#{user.nickname}_id_rsa.pub`
      end
      
    else
      puts 'No current user in gitconfig'
    end
  end

  # Sets _nickname_ as current user
  # @param [String] nickname The nickname to use
  def self.use(nickname)
    self.no_user? nickname
    user = @config[nickname]
    
    @gitconfig.change_user user        # daring change made here!  Heads up Walle
    
    self.show
  end

  # Adds a author to the config
  # @param [String] nickname The nickname of the author
  # @param [String] name The name of the author
  # @param [String] email The email of the author
  def self.add(nickname, name, email)
    self.has_user? nickname
    user = User.new name, email, nickname
    @config.add user
    @config.save!
    
    
    

     
    Ssh.setup_ssh_keys user
    
    #  TODO Gas can automatically install this ssh key into the github account of your choice.  Would you like gas to do this for you?  (requires github username/pass)
    Ssh.upload_public_key_to_github user
    
    puts 'Added author'
    puts user
  end

  # Imports current user from .gitconfig to .gas
  # @param [String] nickname The nickname to give to the new user
  def self.import(nickname)
    self.has_user? nickname
    user = @gitconfig.current_user

    if user
      user = User.new user.name, user.email, nickname

      @config.add user
      @config.save!

      puts 'Added author'
      puts user
    else
      puts 'No current user to import'
    end
  end

  # Deletes a author from the config using nickname
  # @param [String] nickname The nickname of the author
  def self.delete(nickname)
    self.no_user? nickname
    @config.delete nickname
    @config.save!

    puts "Deleted author #{nickname}"
  end

  # Prints the current version
  def self.version
    puts Gas::VERSION
  end

  # Checks if the user exists and gives error and exit if not
  # @param [String] nickname
  def self.no_user?(nickname)
    if !@config.exists? nickname
      puts "Nickname #{nickname} does not exist"
      exit
    end
  end

  # Checks if the user exists and gives error and exit if so
  # @param [String] nickname
  def self.has_user?(nickname)
    if @config.exists? nickname
      puts "Nickname #{nickname} does already exist"
      exit
    end
  end

end
