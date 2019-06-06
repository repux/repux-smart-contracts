---
id: storage_EternalStorage
title: EternalStorage
---

<div class="contract-doc"><div class="contract"><h2 class="contract-header"><span class="contract-kind">contract</span> EternalStorage</h2><p class="base-contracts"><span>is</span> <a href="api_utils_Ownable.md">Ownable</a><span>, </span><a href="api_storage_EternalStorageInterface.md">EternalStorageInterface</a></p><div class="source">Source: <a href="git+https://github.com/repux/repux-smart-contracts/blob/v1.3.1/contracts/storage/EternalStorage.sol" target="_blank">storage/EternalStorage.sol</a></div></div><div class="index"><h2>Index</h2><ul><li><a href="api_storage_EternalStorage.md#addaddresstoarray">addAddressToArray</a></li><li><a href="api_storage_EternalStorage.md#addinttoarray">addIntToArray</a></li><li><a href="api_storage_EternalStorage.md#adduinttoarray">addUintToArray</a></li><li><a href="api_storage_EternalStorage.md#deleteaddress">deleteAddress</a></li><li><a href="api_storage_EternalStorage.md#deletebool">deleteBool</a></li><li><a href="api_storage_EternalStorage.md#deletebytes">deleteBytes</a></li><li><a href="api_storage_EternalStorage.md#deleteint">deleteInt</a></li><li><a href="api_storage_EternalStorage.md#deletestring">deleteString</a></li><li><a href="api_storage_EternalStorage.md#deleteuint">deleteUint</a></li><li><a href="api_storage_EternalStorage.md#">fallback</a></li><li><a href="api_storage_EternalStorage.md#getaddress">getAddress</a></li><li><a href="api_storage_EternalStorage.md#getaddressarray">getAddressArray</a></li><li><a href="api_storage_EternalStorage.md#getbool">getBool</a></li><li><a href="api_storage_EternalStorage.md#getbytes">getBytes</a></li><li><a href="api_storage_EternalStorage.md#getint">getInt</a></li><li><a href="api_storage_EternalStorage.md#getintarray">getIntArray</a></li><li><a href="api_storage_EternalStorage.md#getstring">getString</a></li><li><a href="api_storage_EternalStorage.md#getuint">getUint</a></li><li><a href="api_storage_EternalStorage.md#getuintarray">getUintArray</a></li><li><a href="api_storage_EternalStorage.md#initialized">initialized</a></li><li><a href="api_storage_EternalStorage.md#onlyallowedcontract">onlyAllowedContract</a></li><li><a href="api_storage_EternalStorage.md#removeaddressfromarray">removeAddressFromArray</a></li><li><a href="api_storage_EternalStorage.md#setaddress">setAddress</a></li><li><a href="api_storage_EternalStorage.md#setbool">setBool</a></li><li><a href="api_storage_EternalStorage.md#setbytes">setBytes</a></li><li><a href="api_storage_EternalStorage.md#setint">setInt</a></li><li><a href="api_storage_EternalStorage.md#setstring">setString</a></li><li><a href="api_storage_EternalStorage.md#setuint">setUint</a></li></ul></div><div class="reference"><h2>Reference</h2><div class="modifiers"><h3>Modifiers</h3><ul><li><div class="item modifier"><span id="onlyAllowedContract" class="anchor-marker"></span><h4 class="name">onlyAllowedContract</h4><div class="body"><code class="signature">modifier <strong>onlyAllowedContract</strong><span>() </span></code><hr/></div></div></li></ul></div><div class="functions"><h3>Functions</h3><ul><li><div class="item function"><span id="addAddressToArray" class="anchor-marker"></span><h4 class="name">addAddressToArray</h4><div class="body"><code class="signature">function <strong>addAddressToArray</strong><span>(bytes32 _key, address _value) </span><span>external </span></code><hr/><dl><dt><span class="label-modifiers">Modifiers:</span></dt><dd><a href="api_storage_EternalStorage.md#onlyallowedcontract">onlyAllowedContract </a></dd><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>_key</code> - bytes32</div><div><code>_value</code> - address</div></dd></dl></div></div></li><li><div class="item function"><span id="addIntToArray" class="anchor-marker"></span><h4 class="name">addIntToArray</h4><div class="body"><code class="signature">function <strong>addIntToArray</strong><span>(bytes32 _key, int _value) </span><span>external </span></code><hr/><dl><dt><span class="label-modifiers">Modifiers:</span></dt><dd><a href="api_storage_EternalStorage.md#onlyallowedcontract">onlyAllowedContract </a></dd><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>_key</code> - bytes32</div><div><code>_value</code> - int</div></dd></dl></div></div></li><li><div class="item function"><span id="addUintToArray" class="anchor-marker"></span><h4 class="name">addUintToArray</h4><div class="body"><code class="signature">function <strong>addUintToArray</strong><span>(bytes32 _key, uint _value) </span><span>external </span></code><hr/><dl><dt><span class="label-modifiers">Modifiers:</span></dt><dd><a href="api_storage_EternalStorage.md#onlyallowedcontract">onlyAllowedContract </a></dd><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>_key</code> - bytes32</div><div><code>_value</code> - uint</div></dd></dl></div></div></li><li><div class="item function"><span id="deleteAddress" class="anchor-marker"></span><h4 class="name">deleteAddress</h4><div class="body"><code class="signature">function <strong>deleteAddress</strong><span>(bytes32 _key) </span><span>external </span></code><hr/><dl><dt><span class="label-modifiers">Modifiers:</span></dt><dd><a href="api_storage_EternalStorage.md#onlyallowedcontract">onlyAllowedContract </a></dd><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>_key</code> - bytes32</div></dd></dl></div></div></li><li><div class="item function"><span id="deleteBool" class="anchor-marker"></span><h4 class="name">deleteBool</h4><div class="body"><code class="signature">function <strong>deleteBool</strong><span>(bytes32 _key) </span><span>external </span></code><hr/><dl><dt><span class="label-modifiers">Modifiers:</span></dt><dd><a href="api_storage_EternalStorage.md#onlyallowedcontract">onlyAllowedContract </a></dd><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>_key</code> - bytes32</div></dd></dl></div></div></li><li><div class="item function"><span id="deleteBytes" class="anchor-marker"></span><h4 class="name">deleteBytes</h4><div class="body"><code class="signature">function <strong>deleteBytes</strong><span>(bytes32 _key) </span><span>external </span></code><hr/><dl><dt><span class="label-modifiers">Modifiers:</span></dt><dd><a href="api_storage_EternalStorage.md#onlyallowedcontract">onlyAllowedContract </a></dd><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>_key</code> - bytes32</div></dd></dl></div></div></li><li><div class="item function"><span id="deleteInt" class="anchor-marker"></span><h4 class="name">deleteInt</h4><div class="body"><code class="signature">function <strong>deleteInt</strong><span>(bytes32 _key) </span><span>external </span></code><hr/><dl><dt><span class="label-modifiers">Modifiers:</span></dt><dd><a href="api_storage_EternalStorage.md#onlyallowedcontract">onlyAllowedContract </a></dd><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>_key</code> - bytes32</div></dd></dl></div></div></li><li><div class="item function"><span id="deleteString" class="anchor-marker"></span><h4 class="name">deleteString</h4><div class="body"><code class="signature">function <strong>deleteString</strong><span>(bytes32 _key) </span><span>external </span></code><hr/><dl><dt><span class="label-modifiers">Modifiers:</span></dt><dd><a href="api_storage_EternalStorage.md#onlyallowedcontract">onlyAllowedContract </a></dd><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>_key</code> - bytes32</div></dd></dl></div></div></li><li><div class="item function"><span id="deleteUint" class="anchor-marker"></span><h4 class="name">deleteUint</h4><div class="body"><code class="signature">function <strong>deleteUint</strong><span>(bytes32 _key) </span><span>external </span></code><hr/><dl><dt><span class="label-modifiers">Modifiers:</span></dt><dd><a href="api_storage_EternalStorage.md#onlyallowedcontract">onlyAllowedContract </a></dd><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>_key</code> - bytes32</div></dd></dl></div></div></li><li><div class="item function"><span id="fallback" class="anchor-marker"></span><h4 class="name">fallback</h4><div class="body"><code class="signature">function <strong></strong><span>() </span><span>public </span></code><hr/></div></div></li><li><div class="item function"><span id="getAddress" class="anchor-marker"></span><h4 class="name">getAddress</h4><div class="body"><code class="signature">function <strong>getAddress</strong><span>(bytes32 _key) </span><span>external </span><span>view </span><span>returns  (address) </span></code><hr/><dl><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>_key</code> - bytes32</div></dd><dt><span class="label-return">Returns:</span></dt><dd>address</dd></dl></div></div></li><li><div class="item function"><span id="getAddressArray" class="anchor-marker"></span><h4 class="name">getAddressArray</h4><div class="body"><code class="signature">function <strong>getAddressArray</strong><span>(bytes32 _key) </span><span>external </span><span>view </span><span>returns  (address[]) </span></code><hr/><dl><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>_key</code> - bytes32</div></dd><dt><span class="label-return">Returns:</span></dt><dd>address[]</dd></dl></div></div></li><li><div class="item function"><span id="getBool" class="anchor-marker"></span><h4 class="name">getBool</h4><div class="body"><code class="signature">function <strong>getBool</strong><span>(bytes32 _key) </span><span>external </span><span>view </span><span>returns  (bool) </span></code><hr/><dl><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>_key</code> - bytes32</div></dd><dt><span class="label-return">Returns:</span></dt><dd>bool</dd></dl></div></div></li><li><div class="item function"><span id="getBytes" class="anchor-marker"></span><h4 class="name">getBytes</h4><div class="body"><code class="signature">function <strong>getBytes</strong><span>(bytes32 _key) </span><span>external </span><span>view </span><span>returns  (bytes) </span></code><hr/><dl><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>_key</code> - bytes32</div></dd><dt><span class="label-return">Returns:</span></dt><dd>bytes</dd></dl></div></div></li><li><div class="item function"><span id="getInt" class="anchor-marker"></span><h4 class="name">getInt</h4><div class="body"><code class="signature">function <strong>getInt</strong><span>(bytes32 _key) </span><span>external </span><span>view </span><span>returns  (int) </span></code><hr/><dl><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>_key</code> - bytes32</div></dd><dt><span class="label-return">Returns:</span></dt><dd>int</dd></dl></div></div></li><li><div class="item function"><span id="getIntArray" class="anchor-marker"></span><h4 class="name">getIntArray</h4><div class="body"><code class="signature">function <strong>getIntArray</strong><span>(bytes32 _key) </span><span>external </span><span>view </span><span>returns  (int[]) </span></code><hr/><dl><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>_key</code> - bytes32</div></dd><dt><span class="label-return">Returns:</span></dt><dd>int[]</dd></dl></div></div></li><li><div class="item function"><span id="getString" class="anchor-marker"></span><h4 class="name">getString</h4><div class="body"><code class="signature">function <strong>getString</strong><span>(bytes32 _key) </span><span>external </span><span>view </span><span>returns  (string) </span></code><hr/><dl><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>_key</code> - bytes32</div></dd><dt><span class="label-return">Returns:</span></dt><dd>string</dd></dl></div></div></li><li><div class="item function"><span id="getUint" class="anchor-marker"></span><h4 class="name">getUint</h4><div class="body"><code class="signature">function <strong>getUint</strong><span>(bytes32 _key) </span><span>external </span><span>view </span><span>returns  (uint) </span></code><hr/><dl><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>_key</code> - bytes32</div></dd><dt><span class="label-return">Returns:</span></dt><dd>uint</dd></dl></div></div></li><li><div class="item function"><span id="getUintArray" class="anchor-marker"></span><h4 class="name">getUintArray</h4><div class="body"><code class="signature">function <strong>getUintArray</strong><span>(bytes32 _key) </span><span>external </span><span>view </span><span>returns  (uint[]) </span></code><hr/><dl><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>_key</code> - bytes32</div></dd><dt><span class="label-return">Returns:</span></dt><dd>uint[]</dd></dl></div></div></li><li><div class="item function"><span id="initialized" class="anchor-marker"></span><h4 class="name">initialized</h4><div class="body"><code class="signature">function <strong>initialized</strong><span>() </span><span>public </span></code><hr/><dl><dt><span class="label-modifiers">Modifiers:</span></dt><dd><a href="api_utils_Ownable.md#onlyowner">onlyOwner </a></dd></dl></div></div></li><li><div class="item function"><span id="removeAddressFromArray" class="anchor-marker"></span><h4 class="name">removeAddressFromArray</h4><div class="body"><code class="signature">function <strong>removeAddressFromArray</strong><span>(bytes32 _key, address _value) </span><span>external </span></code><hr/><dl><dt><span class="label-modifiers">Modifiers:</span></dt><dd><a href="api_storage_EternalStorage.md#onlyallowedcontract">onlyAllowedContract </a></dd><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>_key</code> - bytes32</div><div><code>_value</code> - address</div></dd></dl></div></div></li><li><div class="item function"><span id="setAddress" class="anchor-marker"></span><h4 class="name">setAddress</h4><div class="body"><code class="signature">function <strong>setAddress</strong><span>(bytes32 _key, address _value) </span><span>external </span></code><hr/><dl><dt><span class="label-modifiers">Modifiers:</span></dt><dd><a href="api_storage_EternalStorage.md#onlyallowedcontract">onlyAllowedContract </a></dd><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>_key</code> - bytes32</div><div><code>_value</code> - address</div></dd></dl></div></div></li><li><div class="item function"><span id="setBool" class="anchor-marker"></span><h4 class="name">setBool</h4><div class="body"><code class="signature">function <strong>setBool</strong><span>(bytes32 _key, bool _value) </span><span>external </span></code><hr/><dl><dt><span class="label-modifiers">Modifiers:</span></dt><dd><a href="api_storage_EternalStorage.md#onlyallowedcontract">onlyAllowedContract </a></dd><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>_key</code> - bytes32</div><div><code>_value</code> - bool</div></dd></dl></div></div></li><li><div class="item function"><span id="setBytes" class="anchor-marker"></span><h4 class="name">setBytes</h4><div class="body"><code class="signature">function <strong>setBytes</strong><span>(bytes32 _key, bytes _value) </span><span>external </span></code><hr/><dl><dt><span class="label-modifiers">Modifiers:</span></dt><dd><a href="api_storage_EternalStorage.md#onlyallowedcontract">onlyAllowedContract </a></dd><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>_key</code> - bytes32</div><div><code>_value</code> - bytes</div></dd></dl></div></div></li><li><div class="item function"><span id="setInt" class="anchor-marker"></span><h4 class="name">setInt</h4><div class="body"><code class="signature">function <strong>setInt</strong><span>(bytes32 _key, int _value) </span><span>external </span></code><hr/><dl><dt><span class="label-modifiers">Modifiers:</span></dt><dd><a href="api_storage_EternalStorage.md#onlyallowedcontract">onlyAllowedContract </a></dd><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>_key</code> - bytes32</div><div><code>_value</code> - int</div></dd></dl></div></div></li><li><div class="item function"><span id="setString" class="anchor-marker"></span><h4 class="name">setString</h4><div class="body"><code class="signature">function <strong>setString</strong><span>(bytes32 _key, string _value) </span><span>external </span></code><hr/><dl><dt><span class="label-modifiers">Modifiers:</span></dt><dd><a href="api_storage_EternalStorage.md#onlyallowedcontract">onlyAllowedContract </a></dd><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>_key</code> - bytes32</div><div><code>_value</code> - string</div></dd></dl></div></div></li><li><div class="item function"><span id="setUint" class="anchor-marker"></span><h4 class="name">setUint</h4><div class="body"><code class="signature">function <strong>setUint</strong><span>(bytes32 _key, uint _value) </span><span>external </span></code><hr/><dl><dt><span class="label-modifiers">Modifiers:</span></dt><dd><a href="api_storage_EternalStorage.md#onlyallowedcontract">onlyAllowedContract </a></dd><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>_key</code> - bytes32</div><div><code>_value</code> - uint</div></dd></dl></div></div></li></ul></div></div></div>