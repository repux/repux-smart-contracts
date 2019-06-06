---
id: Order
title: Order
---

<div class="contract-doc"><div class="contract"><h2 class="contract-header"><span class="contract-kind">contract</span> Order</h2><p class="base-contracts"><span>is</span> <a href="api_utils_Ownable.md">Ownable</a><span>, </span><a href="api_utils_Versionable.md">Versionable</a><span>, </span><a href="api_interface_OrderInterface.md">OrderInterface</a></p><div class="source">Source: <a href="git+https://github.com/repux/repux-smart-contracts/blob/v1.3.1/contracts/Order.sol" target="_blank">Order.sol</a></div></div><div class="index"><h2>Index</h2><ul><li><a href="api_Order.md#cancelpurchase">cancelPurchase</a></li><li><a href="api_Order.md#">fallback</a></li><li><a href="api_Order.md#fee">fee</a></li><li><a href="api_Order.md#finalise">finalise</a></li><li><a href="api_Order.md#onlydataproduct">onlyDataProduct</a></li><li><a href="api_Order.md#onlyfinalised">onlyFinalised</a></li><li><a href="api_Order.md#price">price</a></li><li><a href="api_Order.md#rate">rate</a></li></ul></div><div class="reference"><h2>Reference</h2><div class="modifiers"><h3>Modifiers</h3><ul><li><div class="item modifier"><span id="onlyDataProduct" class="anchor-marker"></span><h4 class="name">onlyDataProduct</h4><div class="body"><code class="signature">modifier <strong>onlyDataProduct</strong><span>() </span></code><hr/></div></div></li><li><div class="item modifier"><span id="onlyFinalised" class="anchor-marker"></span><h4 class="name">onlyFinalised</h4><div class="body"><code class="signature">modifier <strong>onlyFinalised</strong><span>() </span></code><hr/></div></div></li></ul></div><div class="functions"><h3>Functions</h3><ul><li><div class="item function"><span id="cancelPurchase" class="anchor-marker"></span><h4 class="name">cancelPurchase</h4><div class="body"><code class="signature">function <strong>cancelPurchase</strong><span>() </span><span>external </span></code><hr/><dl><dt><span class="label-modifiers">Modifiers:</span></dt><dd><a href="api_Order.md#onlydataproduct">onlyDataProduct </a></dd></dl></div></div></li><li><div class="item function"><span id="fallback" class="anchor-marker"></span><h4 class="name">fallback</h4><div class="body"><code class="signature">function <strong></strong><span>(address _dataProductAddress, address _owner, address _buyerAddress, string _buyerPublicKey, uint256 _rateDeadline, uint256 _deliveryDeadline, uint256 _price, uint256 _fee, uint16 _version) </span><span>public </span></code><hr/><dl><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>_dataProductAddress</code> - address</div><div><code>_owner</code> - address</div><div><code>_buyerAddress</code> - address</div><div><code>_buyerPublicKey</code> - string</div><div><code>_rateDeadline</code> - uint256</div><div><code>_deliveryDeadline</code> - uint256</div><div><code>_price</code> - uint256</div><div><code>_fee</code> - uint256</div><div><code>_version</code> - uint16</div></dd></dl></div></div></li><li><div class="item function"><span id="fee" class="anchor-marker"></span><h4 class="name">fee</h4><div class="body"><code class="signature">function <strong>fee</strong><span>() </span><span>public </span><span>view </span><span>returns  (uint256) </span></code><hr/><dl><dt><span class="label-return">Returns:</span></dt><dd>uint256</dd></dl></div></div></li><li><div class="item function"><span id="finalise" class="anchor-marker"></span><h4 class="name">finalise</h4><div class="body"><code class="signature">function <strong>finalise</strong><span>(string _buyerMetaHash) </span><span>external </span></code><hr/><dl><dt><span class="label-modifiers">Modifiers:</span></dt><dd><a href="api_Order.md#onlydataproduct">onlyDataProduct </a></dd><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>_buyerMetaHash</code> - string</div></dd></dl></div></div></li><li><div class="item function"><span id="price" class="anchor-marker"></span><h4 class="name">price</h4><div class="body"><code class="signature">function <strong>price</strong><span>() </span><span>public </span><span>view </span><span>returns  (uint256) </span></code><hr/><dl><dt><span class="label-return">Returns:</span></dt><dd>uint256</dd></dl></div></div></li><li><div class="item function"><span id="rate" class="anchor-marker"></span><h4 class="name">rate</h4><div class="body"><code class="signature">function <strong>rate</strong><span>(uint8 score) </span><span>external </span></code><hr/><dl><dt><span class="label-modifiers">Modifiers:</span></dt><dd><a href="api_Order.md#onlyfinalised">onlyFinalised </a><a href="api_Order.md#onlydataproduct">onlyDataProduct </a></dd><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>score</code> - uint8</div></dd></dl></div></div></li></ul></div></div></div>