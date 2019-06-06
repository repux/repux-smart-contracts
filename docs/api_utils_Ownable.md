---
id: utils_Ownable
title: Ownable
---

<div class="contract-doc"><div class="contract"><h2 class="contract-header"><span class="contract-kind">contract</span> Ownable</h2><div class="source">Source: <a href="git+https://github.com/repux/repux-smart-contracts/blob/v1.3.1/contracts/utils/Ownable.sol" target="_blank">utils/Ownable.sol</a></div></div><div class="index"><h2>Index</h2><ul><li><a href="api_utils_Ownable.md#OwnerTransfer">OwnerTransfer</a></li><li><a href="api_utils_Ownable.md#acceptownertransfer">acceptOwnerTransfer</a></li><li><a href="api_utils_Ownable.md#onlyowner">onlyOwner</a></li><li><a href="api_utils_Ownable.md#proposenewowner">proposeNewOwner</a></li></ul></div><div class="reference"><h2>Reference</h2><div class="events"><h3>Events</h3><ul><li><div class="item event"><span id="OwnerTransfer" class="anchor-marker"></span><h4 class="name">OwnerTransfer</h4><div class="body"><code class="signature">event <strong>OwnerTransfer</strong><span>(address originalOwner, address currentOwner) </span></code><hr/><dl><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>originalOwner</code> - address</div><div><code>currentOwner</code> - address</div></dd></dl></div></div></li></ul></div><div class="modifiers"><h3>Modifiers</h3><ul><li><div class="item modifier"><span id="onlyOwner" class="anchor-marker"></span><h4 class="name">onlyOwner</h4><div class="body"><code class="signature">modifier <strong>onlyOwner</strong><span>() </span></code><hr/></div></div></li></ul></div><div class="functions"><h3>Functions</h3><ul><li><div class="item function"><span id="acceptOwnerTransfer" class="anchor-marker"></span><h4 class="name">acceptOwnerTransfer</h4><div class="body"><code class="signature">function <strong>acceptOwnerTransfer</strong><span>() </span><span>public </span></code><hr/></div></div></li><li><div class="item function"><span id="proposeNewOwner" class="anchor-marker"></span><h4 class="name">proposeNewOwner</h4><div class="body"><code class="signature">function <strong>proposeNewOwner</strong><span>(address newOwner) </span><span>public </span></code><hr/><dl><dt><span class="label-modifiers">Modifiers:</span></dt><dd><a href="api_utils_Ownable.md#onlyowner">onlyOwner </a></dd><dt><span class="label-parameters">Parameters:</span></dt><dd><div><code>newOwner</code> - address</div></dd></dl></div></div></li></ul></div></div></div>