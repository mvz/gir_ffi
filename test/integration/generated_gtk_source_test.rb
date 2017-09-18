# frozen_string_literal: true

require 'gir_ffi_test_helper'

# Tests behavior of objects in the generated GtkSource namespace.
describe 'The generated GtkSource module' do
  before do
    begin
      GirFFI.setup :GtkSource
    rescue RuntimeError
      skip 'GtkSource GIR not available'
    end
  end

  describe 'GtkSource::CompletionContext' do
    let(:instance) { GtkSource::CompletionContext.new }

    it 'allows adding proposals' do
      proposals = [
        GtkSource::CompletionItem.new('Proposal 1', 'Proposal 1', nil, 'blah 1'),
        GtkSource::CompletionItem.new('Proposal 2', 'Proposal 2', nil, 'blah 2'),
        GtkSource::CompletionItem.new('Proposal 3', 'Proposal 3', nil, 'blah 3')
      ]
      instance.add_proposals nil, proposals, true
    end
  end
end
