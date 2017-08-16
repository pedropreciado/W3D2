require 'sqlite3'
require 'singleton'



class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end






class Users
  attr_reader :id
  attr_accessor :fname, :lname

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM users")
    data.map { |datum| Users.new(datum) }
  end

  def self.find_by_id(id)
    users = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    return nil unless users.count > 0

    Users.new(users.first) # first array/obj in hash


  end

  def self.find_by_name(fname, lname)
    users = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ?
        AND lname = ?
    SQL

    Users.new(users.first)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_question(id)
    Questions.find_by_author_id(id)
  end

  def authored_replies(id)
    Replies.find_by_user_id(id)
  end

end





class Questions
  attr_accessor :title, :body, :author_id


  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']

  end

  def self.find_by_author_id(author_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
    SQL
  end

  def author
    User.find_by_id(@author_id)
  end

  def replies
    Replies.find_by_question_id(@id)
  end


end





class QuestionsFollows
  attr_accessor :user_id, :question_id

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']

  end
end





class Replies
  attr_accessor :question_id, :author_id, :body, :parent_reply_id

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @author_id = options['author_id']
    @body = options['body']
    @parent_reply_id = options['parent_reply_id']
  end


  def self.find_by_id(id)
    replies_data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL

    Reply.new(reply_data)
  end

  def self.find_by_user_id(user_id)
    replies_data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.author_id = user_id
    SQL

    replies_data.map { |reply_data| Reply.new(reply_data) }
  end

  def self.find_by_question_id(question_id)
    replies_data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL

    replies_data.map { |reply_data| Reply.new(reply_data) }
  end

  def author
    Users.find_by_user_id(@author_id)
  end

  def question
    Questions.find_by_question_id(@question_id)
  end

  def parent_reply
    Replies.find(parent_reply_id)
  end
end




class QuestionLikes
  attr_accessor :user_id, :question_id

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end
