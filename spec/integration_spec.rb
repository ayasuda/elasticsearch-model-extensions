require 'elasticsearch/model/extensions/all'

RSpec.shared_examples 'a normal elasticsearch-model object' do
  describe 'a record creation' do
    before(:each) do
      ::Article.create(title: 'foo', created_at: Time.now)

      ::Article.__elasticsearch__.refresh_index!
    end

    it 'makes the document searchable' do
      expect(Article.search('foo').records.size).to eq(1)
    end
  end

  describe 'a record update' do
    before(:each) do
      Article.first.update_attributes title: 'Test2'

      Article.__elasticsearch__.refresh_index!
    end

    it 'makes the document unsearchable using the old content' do
      expect(Article.search('Test').records.size).to eq(0)
    end

    it 'makes the document searchable using the new content' do
      expect(Article.search('Test2').records.size).to eq(1)
    end
  end

  describe 'a record deletion' do
    before(:each) do
      Article.first.destroy

      Article.__elasticsearch__.refresh_index!
    end

    it 'makes the document unsearchable' do
      expect(Article.search('Test').records.size).to eq(0)
    end
  end
end

RSpec.shared_examples 'an article with comments' do
  describe 'a record creation' do
    before(:each) do
      ::Article.create(title: 'foo', created_at: Time.now, comments_attributes: [{body: 'new_comment'}])

      ::Article.__elasticsearch__.refresh_index!
    end

    it 'makes the document searchable' do
      expect(Article.search('foo').records.size).to eq(1)
      expect(Article.search('new_comment').records.size).to eq(1)
      expect(Article.search(query: {term: {'comments.body' => 'new_comment'}}).records.size).to eq(1)
      expect(Article.search(query: {term: {'num_comments' => 1}}).records.size).to eq(2)
    end
  end

  describe 'a record update' do
    before(:each) do
      Article.first.update_attributes title: 'Test2', comments_attributes: [{body: 'new_comment'}]

      Article.__elasticsearch__.refresh_index!
    end

    it 'makes the document unsearchable using the old content' do
      expect(Article.search('Test').records.size).to eq(0)
    end

    it 'makes the document searchable using the new content' do
      expect(Article.search('Test2').records.size).to eq(1)
      expect(Article.search('new_comment').records.size).to eq(1)
      expect(Article.search(query: {term: {'comments.body' => 'new_comment'}}).records.size).to eq(1)
    end

    it 'updates the dependent field' do
      expect(Article.search(query: {term: {'num_comments' => 1}}).records.size).to eq(2)
    end
  end

  describe 'a record deletion' do
    before(:each) do
      Article.first.destroy

      Article.__elasticsearch__.refresh_index!
    end

    it 'makes the document unsearchable' do
      expect(Article.search('Test').records.size).to eq(0)
    end
  end
end

RSpec.shared_examples 'an author with books' do
  def find_author_by_nickname(name)
    if Author.respond_to?(:find_by)
      # Rails 4
      Author.find_by(nickname: name)
    else
      # Rails 3
      Author.find_by_nickname(name)
    end
  end
  describe 'a record creation' do
    before(:each) do
      ::Author.create(nickname: 'Touma', created_at: Time.now, books_attributes: [{title: 'new_book'}])

      ::Author.__elasticsearch__.refresh_index!
    end

    it 'makes the document searchable' do
      expect(Author.search('Touma').records.size).to eq(1)
      expect(Author.search('new_book').records.size).to eq(1)
      expect(Author.search(query: {term: {'books.title' => 'new_book'}}).records.size).to eq(1)
      expect(Author.search(query: {term: {'num_books' => 2}}).records.size).to eq(1)
      expect(Author.search(query: {term: {'num_books' => 1}}).records.size).to eq(2)
    end
  end

  describe 'a record update' do
    before(:each) do
      find_author_by_nickname('Kuroko').update_attributes nickname: 'Test2', books_attributes: [{title: 'new_book'}]

      Author.__elasticsearch__.refresh_index!
    end

    it 'makes the document unsearchable using the old content' do
      expect(Author.search('Kuroko').records.size).to eq(0)
      expect(Author.search(query: {term: {'num_books' => 2}}).records.size).to eq(0)
    end

    it 'makes the document searchable using the new content' do
      expect(Author.search('Test2').records.size).to eq(1)
      expect(Author.search('new_book').records.size).to eq(1)
      expect(Author.search(query: {term: {'books.title' => 'new_book'}}).records.size).to eq(1)
    end

    it 'updates the dependent field' do
      expect(Author.search(query: {term: {'num_books' => 1}}).records.size).to eq(1)
      expect(Author.search(query: {term: {'num_books' => 3}}).records.size).to eq(1)
    end
  end

  describe 'a record deletion' do
    before(:each) do
      find_author_by_nickname('Kuroko').destroy

      Author.__elasticsearch__.refresh_index!
    end

    it 'makes the document unsearchable' do
      expect(Author.search('Kuroko').records.size).to eq(0)
    end
  end

  # TODO Describe about logical deletion
  # TODO Describe behaviors when tags are updated
end

RSpec.describe 'integration' do
  context 'with articles' do
    before :each do
      load 'setup/articles.rb'
    end

    after :each do
      ActiveRecord::Schema.define(:version => 2) do
        drop_table :articles
      end
    end

    it_behaves_like 'a normal elasticsearch-model object'
  end

  context 'with articles_with_comments_and_delayed_jobs' do
    before(:each) do
      load 'setup/articles_with_comments_and_delayed_jobs.rb'
    end

    after(:each) do
      ActiveRecord::Schema.define(:version => 2) do
        drop_table :articles
        drop_table :comments
        drop_table :delayed_jobs
      end
    end

    it_behaves_like 'a normal elasticsearch-model object'
  end

  context 'with authors_and_books_with_tas.rb' do
    before(:each) do
      load 'setup/authors_and_books_with_tags.rb'
    end

    after(:each) do
      ActiveRecord::Schema.define(:version => 2) do
        drop_table :books
        drop_table :tags
        drop_table :author_profiles
        drop_table :authors
      end
    end

    # it_behaves_like 'a normal elasticsearch-model object'
    # it_behaves_like 'an article with comments'
    it_behaves_like 'an author with books'
  end
end
