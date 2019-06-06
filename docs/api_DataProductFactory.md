---
id: DataProductFactory
title: DataProductFactory
---

<div class="contract-doc"><div class="contract"><h2 class="contract-header"><span class="contract-kind">contract</span> DataProductFactory</h2><p class="base-contracts"><span>is</span> <a href="api_utils_Ownable.md">Ownable</a><span>, </span><a href="api_utils_Versionable.md">Versionable</a><span>, </span><a href="api_interface_DataProductFactoryInterface.md">DataProductFactoryInterface</a></p><div class="source">Source: <a href="git+https://github.com/repux/repux-smart-contracts/blob/v1.3.1/contracts/DataProductFactory.sol" target="_blank">DataProductFactory.sol</a></div></div><div class="index"><h2>Index</h2><ul><li><a href="api_DataProductFactory.md#createdataproduct">createDataProduct</a></li><li><a href="api_DataProductFactory.md#">fallback</a></li><li><a href="api_DataProductFactory.md#onlyregistry">onlyRegistry</a></li><li><a href="api_DataProductFactory.md#setregistry">setRegistry</a></li></ul></div><div class="reference"><h2>Reference</h2><div class="modifiers"><h3>Modifiers</h3><ul><li><div class="item modifier"><span id="onlyRegistry" class="anchor-marker"></span><h4 class="name">onlyRegistry</h4><div class="body"><code class="signature">modifier <strong>onlyRegistry</strong><span>() </span></code><hr/></div></div></li></ul></div><div class="functions"><h3>Functions</h3><ul><li><div class="item function"><span id="createDataProduct" class="anchor-marker"></span><h4 class="name">createDataProduct</h4><div class="body"><code class="signature">function <strong>createDataProduct</strong><span>(address _orderFactoryAddress, address _owner, address _tokenAddress, string _sellerMetaHash, uint256 _price, uint8 _daysToDeliver) </span><span>public </span><span>returns  (address) </span></code><hr/><dl><dt><span class="label-modifiers">Modifiers:</span></dt><dd><a href="api_DataProductFactory.md#onlyregistry">onlyRegistry </a></dd><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>_orderFactoryAddress</code> - address</div><div><code>_owner</code> - address</div><div><code>_tokenAddress</code> - address</div><div><code>_sellerMetaHash</code> - string</div><div><code>_price</code> - uint256</div><div><code>_daysToDeliver</code> - uint8</div></dd><dt><span class="label-return">Returns:</span></dt><dd>address</dd></dl></div></div></li><li><div class="item function"><span id="fallback" class="anchor-marker"></span><h4 class="name">fallback</h4><div class="body"><code class="signature">function <strong></strong><span>() </span><span>public </span></code><hr/></div></div></li><li><div class="item function"><span id="setRegistry" class="anchor-marker"></span><h4 class="name">setRegistry</h4><div class="body"><code class="signature">function <strong>setRegistry</strong><span>(address _registryAddress) </span><span>public </span></code><hr/><dl><dt><span class="label-modifiers">Modifiers:</span></dt><dd><a href="api_utils_Ownable.md#onlyowner">onlyOwner </a></dd><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>_registryAddress</code> - address</div></dd></dl></div></div></li></ul></div></div></div>