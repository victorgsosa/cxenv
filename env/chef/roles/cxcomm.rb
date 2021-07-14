description 'Install CX Commerce v 2005'
name 'cxcomm'
override_attributes 'cxcomm' => {
	'user' => {
		'user' => 'cxcomm',
		'group' => 'cxcomm'
	},
	'install' => {
		'version' => '2005',
		'download_url' => 'file:///tmp/cx/CXCOM200500P_14-70004955.zip',
		'download_checksum' => 'ea93ca6cc7503dcd1e82c2f9aeb5f4733d92611dfa3d9ca42bc116151676ccd4',
		'install_spartacus' => true,
		'install_ip' => true,
		'ip_download_url' => 'file:///tmp/cx/CXCOMINTPK200500P_0-80005540.zip',
		'ip_download_checksum' => '7bf5d9326c38bcb759288422c56577f1da1e5931b4e36cc1c7f04aa7fa76eb04'
	}
}

run_list 'recipe[cxcomm]'