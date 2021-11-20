# frozen_string_literal: true

require "gir_ffi_test_helper"

GirFFI.setup :GtkSource, "3.0"

# Tests behavior of objects in the generated GtkSource namespace.
describe GtkSource do
  describe "GtkSource::CompletionContext" do
    let(:instance) { GtkSource::CompletionContext.new }

    it "allows adding proposals" do
      proposals = [
        GtkSource::CompletionItem.new("Proposal 1", "Proposal 1", nil, "blah 1"),
        GtkSource::CompletionItem.new("Proposal 2", "Proposal 2", nil, "blah 2"),
        GtkSource::CompletionItem.new("Proposal 3", "Proposal 3", nil, "blah 3")
      ]
      instance.add_proposals nil, proposals, true
    end
  end
end
