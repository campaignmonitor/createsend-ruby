libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'createsend/version'
require 'createsend/createsend'
require 'createsend/client'
require 'createsend/campaign'
require 'createsend/list'
require 'createsend/segment'
require 'createsend/subscriber'
require 'createsend/template'
require 'createsend/person'
require 'createsend/administrator'
require 'createsend/transactional_classic_email'
require 'createsend/transactional_smart_email'
require 'createsend/transactional_timeline'
