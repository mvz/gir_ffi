# frozen_string_literal: true

require 'gir_ffi_test_helper'

GirFFI.setup :GtkSource

# Tests behavior of objects in the generated GtkSource namespace.
describe 'The generated GtkSource module' do
  describe 'GtkSource::CompletionContext' do
    let(:instance) { GtkSource::CompletionContext.new }

    it 'allows adding proposals' do
      # Interface changed in GtkSourceView 3.24
      proposals = if GtkSource::CompletionItem.instance_methods.include? :set_label
                    Array.new(3) do |i|
                      GtkSource::CompletionItem.new.tap do |item|
                        item.label = "Proposal #{i}"
                        item.text =  "Proposal #{i}"
                        item.info = "blah #{i}"
                      end
                    end
                  else
                    [
                      GtkSource::CompletionItem.new('Proposal 1', 'Proposal 1', nil, 'blah 1'),
                      GtkSource::CompletionItem.new('Proposal 2', 'Proposal 2', nil, 'blah 2'),
                      GtkSource::CompletionItem.new('Proposal 3', 'Proposal 3', nil, 'blah 3')
                    ]
                  end
      instance.add_proposals nil, proposals, true
    end
  end
end
