#pragma once

#include "cryptonote_basic.h"
#include "crypto/crypto.h"


namespace cryptonote
{

  struct account_keys
  {
    account_public_address m_account_address;
    crypto::secret_key   m_spend_secret_key;
    crypto::secret_key   m_view_secret_key;
    std::vector<crypto::secret_key> m_multisig_keys;
      };

class account_base
  {
  public:
    account_base();
    crypto::secret_key generate(const crypto::secret_key& recovery_key = crypto::secret_key(), bool recover = false, bool two_random = false);
    void create_from_device(const std::string &device_name);
    void create_from_keys(const cryptonote::account_public_address& address, const crypto::secret_key& spendkey, const crypto::secret_key& viewkey);
    void create_from_viewkey(const cryptonote::account_public_address& address, const crypto::secret_key& viewkey);
    bool make_multisig(const crypto::secret_key &view_secret_key, const crypto::secret_key &spend_secret_key, const crypto::public_key &spend_public_key, const std::vector<crypto::secret_key> &multisig_keys);
    void finalize_multisig(const crypto::public_key &spend_public_key);
    const account_keys& get_keys() const;

    uint64_t get_createtime() const { return m_creation_timestamp; }
    void set_createtime(uint64_t val) { m_creation_timestamp = val; }

    void forget_spend_key();
    const std::vector<crypto::secret_key> &get_multisig_keys() const { return m_keys.m_multisig_keys; }

    void generate_public_edkey();
    
    template <class t_archive>
    inline void serialize(t_archive &a, const unsigned int /*ver*/)
    {
      a & m_keys;
      a & m_creation_timestamp;
    }

  private:
    void set_null();
    account_keys m_keys;
    uint64_t m_creation_timestamp;
  };
}
