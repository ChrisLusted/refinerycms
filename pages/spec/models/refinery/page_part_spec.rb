# encoding: utf-8
require 'spec_helper'

module Refinery
  describe Page do
    let(:page_title) { 'RSpec is great for testing too' }
    let(:page) { subject.class.new(:title => page_title, :deletable => true)}

    before do
      page.parts.new(:title => 'body', :content => "I'm the first page part for this page.", :position => 0)
      page.parts.new(:title => 'side body', :content => 'Closely followed by the second page part.', :position => 1)
    end

    it 'return the content when using content_for' do
      expect(page.content_for(:body)).to eq("<p>I'm the first page part for this page.</p>")
      expect(page.content_for('BoDY')).to eq("<p>I'm the first page part for this page.</p>")
    end

    it 'requires a unique title' do
      page.save
      page.parts.create(:title => 'body')
      duplicate_title_part = page.parts.create(:title => 'body')

      expect(duplicate_title_part.errors[:title]).to be_present
    end

    it 'only requires a unique title on the same page' do
      part_one = Page.create(:title => 'first page').parts.create(:title => 'body')
      part_two = Page.create(:title => 'second page').parts.create(:title => 'body')

      expect(part_two.errors[:title]).to be_empty
    end

    context 'when using content_for?' do

      it 'return true when page part has content' do
        expect(page.content_for?(:body)).to be_truthy
      end

      it 'return false when page part does not exist' do
        page.parts = []
        expect(page.content_for?(:body)).to be_falsey
      end

      it 'return false when page part does not have any content' do
        page.parts.first.content = ''
        expect(page.content_for?(:body)).to be_falsey
      end

    end

    it 'reposition correctly' do
      page.save

      page.parts.first.update_columns position: 6
      page.parts.last.update_columns position: 4

      expect(page.parts.first.position).to eq(6)
      expect(page.parts.last.position).to eq(4)

      page.reposition_parts!

      expect(page.parts.first.position).to eq(0)
      expect(page.parts.last.position).to eq(1)
    end
  end
end
