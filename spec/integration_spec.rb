require 'elasticsearch/model/extensions/all'

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
end
