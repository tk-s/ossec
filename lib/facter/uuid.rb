#
# uuid.rb
#
# This fact provides unique system identification in form of an RFC 4122
# compliant UUID version 5 type identifier.  Currently we generate said
# UUID using SHA-1 hash and rely on the "fqdn" (fully-qualified domain
# name) fact availability since we use DNS name space when generating
# the UUID version 5 to be compliment with the standards ...
#
# There is probably a room for discussion on the matter of which type
# of UUID should be used i.e. UUID version 1 versus UUID version 5.
#
# Personally, I rely more on host name and generally on fully-qualified
# domain name these days over trusting that the same MAC address will
# be allocated to me upon re-building EC2 instance or generally working
# with virtual machines.  No to mention that reasonable accuracy of
# the monotonic clock on such systems is also a matter of discussion ...
#
# Please consult http://www.ietf.org/rfc/rfc4122.txt for the details on
# UUID generation and example implementation.
#

if Facter.value(:kernel) == 'Linux'
  # We change status on any errors ...
  errors = false

  # This is probably impossible as Digest is part of the Ruby Core ...
  begin
    require 'digest/sha1'
  rescue LoadError
    # Mark that there was an error ...
    errors = true

    # Usefulness of both Facter.debug and Facter.warn is a matter of discussion ...
    Facter.warn 'Unable to load Digest::SHA1 library.'
  end

  # Check for potential errors before continuing ...
  unless errors
    #
    # The String#bytes method was added in 1.8.7 (and now is present in any
    # recent version) therefore we monkey-patch String if such is missing ...
    #
    unless String.method_defined?(:bytes)
      class String
        def bytes(&block)
          # This should not be necessary, really ...
          require 'enumerator'
          return to_enum(:each_byte) unless block_given?
          each_byte(&block)
        end
      end
    end

    #
    # This is the UUID version 5 type DNS name space which is as follows:
    #
    #  6ba7b810-9dad-11d1-80b4-00c04fd430c8
    #
    uuid_name_space_dns = "\x6b\xa7\xb8\x10\x9d\xad\x11\xd1" +
                          "\x80\xb4\x00\xc0\x4f\xd4\x30\xc8"

    sha1 = Digest::SHA1.new

    # Resolve the "fqdn" fact and therefore get fully-qualified domain name ...
    domain = Facter.value('fqdn')

    # Concatenate appropriate UUID name space with the domain name given ...
    sha1.update(uuid_name_space_dns)
    sha1.update(domain)

    #
    # We only need to use first 16 bytes and use of String#bytes should be
    # more portable between Rubies 1.8.x and 1.9.x, with the exception of
    # anything prior to version 1.8.7 where String#bytes was added ...
    #
    bytes = sha1.digest[0, 16].bytes.to_a

    # We adjust version to be 5 correctly ...
    bytes[6] &= 0x0f
    bytes[6] |= 0x50

    # We adjust variant to be DCE 1.1 ...
    bytes[8] &= 0x3f
    bytes[8] |= 0x80

    #
    # We turn raw bytes into an user-friendly UUID string representation.
    # The values 4, 2, 2, 2 and 6 denote how many bytes we collect at once
    # giving the total of 16 bytes (128 bits) ...
    #
    value = [4, 2, 2, 2, 6].collect {|i| bytes.slice!(0, i).pack('C*').unpack('H*') }.join('-')

    valuenum = value.to_i(36).to_s[0..7]

    Facter.add('uuid') do
      confine :kernel => :linux
      setcode { value }
    end
    Facter.add('ossec_id') do
      confine :kernel => :linux
      setcode { valuenum }
    end
  end
end

# vim: set ts=2 sw=2 et :
# encoding: utf-8
