Run:
```
yarn
npm install -g truffle typescript ethereumjs-testrpc
testrpc
truffle compile
yarn migrate
yarn test
```

In case of problems with contracts on local environment try to use `tsc && truffle migrate --reset` 
command instead of `yarn migrate`.
